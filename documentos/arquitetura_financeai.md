# Plano de Arquitetura para Reescrita do FinanceAI

## 1. Visão Geral da Arquitetura

Implementaremos uma arquitetura limpa (Clean Architecture) com MVVM para a camada de apresentação, utilizando Flutter e seguindo princípios SOLID. A estrutura será organizada em camadas bem definidas:

- **Data**: Responsável pelo acesso a dados, utilizando SQLite
- **Domain**: Contém a lógica de negócios e modelos de domínio
- **Presentation**: Implementa o padrão MVVM com ViewModels e States

### Tecnologias Core:
- Flutter (UI)
- Riverpod (Gerenciamento de estado e DI)
- sqflite (Banco de dados local)
- intl (Internacionalização e formatação)
- fl_chart (Visualizações gráficas)

## 2. Modelo de Dados

### Tabelas do Banco de Dados

#### accounts (Contas)
```sql
CREATE TABLE accounts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT NOT NULL, -- 'cash', 'bank', 'credit_card'
    initial_balance INTEGER NOT NULL, -- em centavos
    current_balance INTEGER NOT NULL, -- em centavos
    credit_limit INTEGER, -- para cartões de crédito
    due_day INTEGER, -- dia de vencimento para cartões
    close_day INTEGER, -- dia de fechamento para cartões
    color TEXT, -- cor para identificação visual
    icon TEXT, -- ícone para identificação visual
    is_active BOOLEAN NOT NULL DEFAULT 1,
    is_default BOOLEAN NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);
```

#### categories (Categorias)
```sql
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT NOT NULL, -- 'income', 'expense', 'transfer'
    color TEXT,
    icon TEXT,
    parent_id INTEGER, -- para categorias hierárquicas
    is_system BOOLEAN NOT NULL DEFAULT 0, -- categorias pré-definidas
    is_active BOOLEAN NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (parent_id) REFERENCES categories (id) ON DELETE SET NULL
);
```

#### payees (Beneficiários/Pagadores)
```sql
CREATE TABLE payees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT 1,
    default_category_id INTEGER, -- categoria padrão
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (default_category_id) REFERENCES categories (id) ON DELETE SET NULL
);
```

#### transactions (Transações)
```sql
CREATE TABLE transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    payee_id INTEGER,
    amount INTEGER NOT NULL, -- em centavos
    date TEXT NOT NULL,
    type TEXT NOT NULL, -- 'income', 'expense', 'transfer'
    description TEXT,
    status TEXT NOT NULL DEFAULT 'confirmed', -- 'confirmed', 'pending', 'cancelled'
    recurrence_id INTEGER, -- para transações recorrentes
    installment_id INTEGER, -- para transações parceladas
    installment_number INTEGER, -- número da parcela
    total_installments INTEGER, -- total de parcelas
    transfer_account_id INTEGER, -- para transferências
    is_credit_card_bill BOOLEAN NOT NULL DEFAULT 0, -- pagamento de fatura
    bill_id INTEGER, -- referência à fatura (para cartões)
    auto_categorized BOOLEAN NOT NULL DEFAULT 0,
    categorization_confidence REAL,
    is_out_of_budget BOOLEAN NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE,
    FOREIGN KEY (payee_id) REFERENCES payees (id) ON DELETE SET NULL,
    FOREIGN KEY (recurrence_id) REFERENCES recurrences (id) ON DELETE SET NULL,
    FOREIGN KEY (installment_id) REFERENCES installments (id) ON DELETE SET NULL,
    FOREIGN KEY (transfer_account_id) REFERENCES accounts (id) ON DELETE SET NULL,
    FOREIGN KEY (bill_id) REFERENCES credit_card_bills (id) ON DELETE SET NULL
);
```

#### recurrences (Recorrências)
```sql
CREATE TABLE recurrences (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    rule TEXT NOT NULL, -- 'monthly', 'weekly', 'yearly', etc.
    frequency INTEGER NOT NULL DEFAULT 1,
    start_date TEXT NOT NULL,
    end_date TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);
```

#### installments (Parcelamentos)
```sql
CREATE TABLE installments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    original_transaction_id INTEGER,
    total_amount INTEGER NOT NULL, -- valor total em centavos
    installment_count INTEGER NOT NULL, -- número total de parcelas
    start_date TEXT NOT NULL,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (original_transaction_id) REFERENCES transactions (id) ON DELETE SET NULL
);
```

#### budgets (Orçamentos)
```sql
CREATE TABLE budgets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER NOT NULL,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    amount INTEGER NOT NULL, -- em centavos
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE,
    UNIQUE (category_id, year, month)
);
```

#### credit_card_bills (Faturas de Cartão)
```sql
CREATE TABLE credit_card_bills (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id INTEGER NOT NULL,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    due_date TEXT NOT NULL,
    close_date TEXT NOT NULL,
    total_amount INTEGER NOT NULL, -- valor total em centavos
    status TEXT NOT NULL DEFAULT 'open', -- 'open', 'closed', 'paid'
    payment_transaction_id INTEGER,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE,
    FOREIGN KEY (payment_transaction_id) REFERENCES transactions (id) ON DELETE SET NULL
);
```

#### categorization_data (Dados para Categorização Automática)
```sql
CREATE TABLE categorization_data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    term TEXT NOT NULL,
    type TEXT NOT NULL, -- 'keyword', 'payee', 'amount'
    category_id INTEGER NOT NULL,
    weight REAL NOT NULL DEFAULT 1.0,
    occurrences INTEGER NOT NULL DEFAULT 1,
    last_occurrence TEXT NOT NULL,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
);
```

#### ai_insights (Insights de IA)
```sql
CREATE TABLE ai_insights (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT NOT NULL, -- 'saving_opportunity', 'forecast', 'goal_progress'
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    data TEXT, -- JSON serializado com dados específicos
    is_read BOOLEAN NOT NULL DEFAULT 0,
    priority INTEGER NOT NULL DEFAULT 0,
    expiry_date TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);
```

#### financial_goals (Metas Financeiras)
```sql
CREATE TABLE financial_goals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    target_amount INTEGER NOT NULL, -- em centavos
    current_amount INTEGER NOT NULL DEFAULT 0, -- em centavos
    target_date TEXT,
    account_id INTEGER,
    category_id INTEGER,
    status TEXT NOT NULL DEFAULT 'active', -- 'active', 'completed', 'canceled'
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE SET NULL,
    FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
);
```

## 3. Estrutura de Diretórios

```
lib/
├── app.dart
├── main.dart
├── config/
│   ├── constants/
│   ├── routes.dart
│   ├── themes.dart
│   └── app_settings.dart
├── core/
│   ├── extensions/
│   ├── utils/
│   ├── error/
│   └── enums/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── database_helper.dart
│   │   │   └── tables/
│   │   │       ├── accounts_table.dart
│   │   │       ├── categories_table.dart
│   │   │       └── ...
│   │   └── remote/
│   ├── repositories/
│   │   ├── account_repository_impl.dart
│   │   ├── transaction_repository_impl.dart
│   │   └── ...
│   └── models/
│       ├── account_model.dart
│       ├── transaction_model.dart
│       └── ...
├── domain/
│   ├── entities/
│   │   ├── account.dart
│   │   ├── transaction.dart
│   │   └── ...
│   ├── repositories/
│   │   ├── account_repository.dart
│   │   ├── transaction_repository.dart
│   │   └── ...
│   ├── usecases/
│   │   ├── account/
│   │   │   ├── get_accounts.dart
│   │   │   ├── create_account.dart
│   │   │   └── ...
│   │   ├── transaction/
│   │   │   ├── get_transactions.dart
│   │   │   ├── create_transaction.dart
│   │   │   └── ...
│   │   └── ...
│   └── services/
│       ├── ai_service.dart
│       ├── categorization_service.dart
│       └── ...
├── presentation/
│   ├── di/
│   │   └── providers.dart
│   ├── shared/
│   │   ├── widgets/
│   │   ├── theme/
│   │   └── utils/
│   └── features/
│       ├── accounts/
│       │   ├── viewmodels/
│       │   │   ├── account_list_viewmodel.dart
│       │   │   ├── account_form_viewmodel.dart
│       │   │   └── account_detail_viewmodel.dart
│       │   ├── states/
│       │   │   ├── account_list_state.dart
│       │   │   ├── account_form_state.dart
│       │   │   └── account_detail_state.dart
│       │   └── screens/
│       │       ├── account_list_screen.dart
│       │       ├── account_form_screen.dart
│       │       └── account_detail_screen.dart
│       ├── transactions/
│       ├── budgets/
│       ├── categories/
│       ├── payees/
│       ├── reports/
│       ├── insights/
│       └── settings/
└── l10n/
    ├── intl_en.arb
    └── intl_pt.arb
```

## 4. Abordagem de Implementação

### Fase 1: Infraestrutura Básica

1. Configuração do projeto Flutter
   - Dependências
   - Tema e estilo

2. Implementação da camada de dados
   - DatabaseHelper
   - Tabelas e modelos
   - DAOs básicos

3. Estrutura de injeção de dependência
   - Riverpod providers para repositórios
   - Configuração de estados

### Fase 2: Recursos Essenciais

1. Contas
   - CRUD de contas
   - Visualização de saldo

2. Categorias
   - Categorias padrão (receita, despesa, transferência)
   - CRUD de categorias personalizadas

3. Beneficiários/Pagadores
   - CRUD de beneficiários
   - Associação com categorias padrão

4. Transações básicas
   - Registro de receitas e despesas
   - Categorização manual

### Fase 3: Recursos Avançados

1. Recorrências e parcelamentos
   - Transações recorrentes
   - Parcelamentos com controle automático

2. Cartões de crédito
   - Gestão de faturas
   - Fechamento e pagamento automático

3. Orçamentos
   - Definição de limites por categoria
   - Monitoramento de progresso

4. Transferências
   - Entre contas próprias
   - Controle de saldo automático

### Fase 4: AI e Insights

1. Categorização automática
   - Treinamento com dados do usuário
   - Sugestões de categorias

2. Previsões financeiras
   - Projeção de gastos futuros
   - Análise de tendências

3. Recomendações de economia
   - Identificação de oportunidades
   - Sugestões personalizadas

4. Planejamento de metas
   - Definição de objetivos financeiros
   - Acompanhamento de progresso

## 5. Padrões Técnicos e Boas Práticas

### Gerenciamento de Estado
- Estados imutáveis com Freezed
- Padrão MVVM consistente
- Hierarquia clara de providers

### Validação e Tratamento de Erros
- Validação em camadas (UI e domínio)
- Tratamento centralizado de exceções
- Estados de erro explícitos

### Testes
- Testes unitários para lógica de negócios
- Testes de widgets para UI
- Mocks para repositórios e serviços

### Segurança
- Dados sensíveis encriptados
- Isolamento de secrets
- Validação de entrada

### Performance
- Lazy loading de dados
- Otimização de consultas SQLite
- Caching inteligente

## 6. Implementação da IA

### Categorização Automática
- Algoritmo baseado em frequência e relevância
- Aprendizado com feedback do usuário
- Palavra-chave, beneficiário e valor como fatores

### Análise de Padrões
- Detecção de gastos recorrentes
- Identificação de anomalias
- Agrupamento inteligente

### Previsões Financeiras
- Modelos de séries temporais
- Análise de sazonalidade
- Projeção de fluxo de caixa

### Recomendações Personalizadas
- Oportunidades de economia
- Sugestões de investimento
- Alertas de gastos excessivos

## 7. Fluxo de Dados

### Transações
1. Usuário registra transação → UI
2. ViewModel valida dados → State
3. UseCase processa regras de negócio
4. Repository persiste no banco de dados
5. ViewModel atualiza saldos e orçamentos
6. Serviço de IA processa para insights

### Orçamentos
1. Usuário define orçamentos por categoria
2. Sistema monitora gastos em relação ao orçamento
3. Notificações automáticas ao atingir limites
4. IA sugere ajustes com base no histórico

### Metas Financeiras
1. Usuário define meta e prazo
2. Sistema calcula quantia necessária mensal
3. IA sugere categorias para economizar
4. Monitoramento automático de progresso

## 8. Experiência do Usuário

### Dashboard Principal
- Visão geral de contas e saldos
- Resumo de receitas e despesas do mês
- Próximas transações previstas
- Insights da IA em destaque

### Consultas e Filtros
- Filtros avançados por período, categoria, conta
- Busca por texto em descrições e beneficiários
- Agrupamentos personalizáveis
- Exportação de relatórios

### Visualizações
- Gráficos de evolução mensal
- Distribuição de gastos por categoria
- Comparativo com meses anteriores
- Projeções futuras

## 9. Migração e Dados Iniciais

Para facilitar a adoção pelo usuário, implementaremos:

1. Sistema de categorias pré-definidas
   - Categorias comuns de despesas (alimentação, moradia, transporte)
   - Categorias de receita (salário, investimentos)
   - Categorias de transferência

2. Assistente de primeira configuração
   - Cadastro de contas principais
   - Definição de orçamento inicial
   - Preferências de notificações

3. Dados de exemplo (opcional)
   - Transações de demonstração
   - Orçamentos sugeridos
   - Insights de exemplo

Este plano fornece uma base sólida para a reescrita do FinanceAI, com foco em arquitetura limpa, manutenibilidade e experiência do usuário. A implementação por fases permite entregar valor incrementalmente enquanto mantém a qualidade do código.