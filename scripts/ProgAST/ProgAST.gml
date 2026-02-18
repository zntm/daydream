
/* AST Node types */
enum PROG_AST
{
    /* Literals */
    NUMBER_LITERAL, STRING_LITERAL, BOOL_LITERAL, UNDEFINED_LITERAL, REGEX_LITERAL,
    ARRAY_LITERAL, OBJECT_LITERAL,
    
    /* Expressions */
    IDENTIFIER, BINARY_OP, UNARY_OP, CALL, INDEX, MEMBER,
    ASSIGNMENT, TERNARY, PREFIX_OP, POSTFIX_OP,
    
    /* Statements */
    STATEMENT, /* Generic/Error statement */
    VAR_DECL, GLOBAL_DECL, IF_STMT, WHILE_STMT, FOR_STMT, REPEAT_STMT,
    BREAK_STMT, CONTINUE_STMT, RETURN_STMT, BLOCK,
    EXPRESSION_STMT, SWITCH_STMT, FUNC_DECL, FUNC_EXPR,
    
    /* New */
    FOR_IN_STMT, TRY_STMT, DESTRUCTURING_DECL,
    IMPORT_STMT, EXPORT_STMT, THROW_STMT,
    
    /* Class System */
    CLASS_DECL, NEW_EXPR, THIS_EXPR, SUPER_EXPR,
    
    /* New v2 */
    IN_EXPR, RANGE_EXPR, OPTIONAL_MEMBER, OPTIONAL_INDEX
}

/* Base AST node */
function ProgASTNode(_type) constructor
{
    type = _type;
    line = 0;
}

/* Binary operation node (e.g. a + b) */
function ProgASTBinaryOp(_op, _left, _right) : ProgASTNode(PROG_AST.BINARY_OP) constructor
{
    op = _op;
    left = _left;
    right = _right;
}

/* Unary operation node (e.g. -a, !b) */
function ProgASTUnaryOp(_op, _right) : ProgASTNode(PROG_AST.UNARY_OP) constructor
{
    op = _op;
    right = _right;
}

/* Literal node (number, string, bool) */
function ProgASTLiteral(_type, _value) : ProgASTNode(_type) constructor
{
    value = _value;
}

/* Array literal node (e.g. [1, 2, 3]) */
function ProgASTArrayLiteral(_elements) : ProgASTNode(PROG_AST.ARRAY_LITERAL) constructor
{
    elements = _elements;
}

/* Object literal node (e.g. {a: 1, b: 2}) */
function ProgASTObjectLiteral(_pairs) : ProgASTNode(PROG_AST.OBJECT_LITERAL) constructor
{
    pairs = _pairs; /* Array of {key, value} structs */
}

/* Identifier node (variable access) */
function ProgASTIdentifier(_name) : ProgASTNode(PROG_AST.IDENTIFIER) constructor
{
    name = _name;
}

/* Assignment node (a = b) */
function ProgASTAssignment(_target, _value, _op = PROG_TOKEN.ASSIGN) : ProgASTNode(PROG_AST.ASSIGNMENT) constructor
{
    target = _target; /* Can be Identifier, Index, or Member */
    value = _value;
    op = _op; /* For +=, -= etc. */
}

/* Call node (function(a, b)) */
function ProgASTCall(_callee, _args) : ProgASTNode(PROG_AST.CALL) constructor
{
    callee = _callee;
    args = _args;
}

/* Index access node (arr[i]) */
function ProgASTIndex(_target, _index) : ProgASTNode(PROG_AST.INDEX) constructor
{
    target = _target;
    index = _index;
}

/* Member access node (obj.prop) */
function ProgASTMember(_target, _property) : ProgASTNode(PROG_AST.MEMBER) constructor
{
    target = _target;
    property = _property; /* Identifier string */
}

/* Ternary op node (cond ? true : false) */
function ProgASTTernary(_condition, _true_branch, _false_branch) : ProgASTNode(PROG_AST.TERNARY) constructor
{
    condition = _condition;
    true_branch = _true_branch;
    false_branch = _false_branch;
}

/* Expression statement (wrapper for expressions used as statements) */
function ProgASTExpressionStmt(_expression) : ProgASTNode(PROG_AST.EXPRESSION_STMT) constructor
{
    expression = _expression;
}

/* Block statement ({ stmt1; stmt2; }) */
function ProgASTBlock(_statements) : ProgASTNode(PROG_AST.BLOCK) constructor
{
    statements = _statements;
}

/* Generic/Error Statement */
function ProgASTStatement() : ProgASTNode(PROG_AST.STATEMENT) constructor
{
}

/* Var declaration (var x = 10) */
function ProgASTVarDecl(_name, _initializer) : ProgASTNode(PROG_AST.VAR_DECL) constructor
{
    name = _name;
    initializer = _initializer;
}

/* Global declaration (global.x = 10 -> handled as assignment, but this could be 'global var x' if we supported it) */
function ProgASTGlobalDecl(_name) : ProgASTNode(PROG_AST.GLOBAL_DECL) constructor
{
    name = _name;
}

/* If statement */
function ProgASTIfStmt(_condition, _then_branch, _else_branch) : ProgASTNode(PROG_AST.IF_STMT) constructor
{
    condition = _condition;
    then_branch = _then_branch;
    else_branch = _else_branch;
}

/* While statement */
function ProgASTWhileStmt(_condition, _body) : ProgASTNode(PROG_AST.WHILE_STMT) constructor
{
    condition = _condition;
    body = _body;
}

/* Repeat statement (repeat 5 { ... }) */
function ProgASTRepeatStmt(_count, _body) : ProgASTNode(PROG_AST.REPEAT_STMT) constructor
{
    count = _count;
    body = _body;
}

/* For statement */
function ProgASTForStmt(_initializer, _condition, _increment, _body) : ProgASTNode(PROG_AST.FOR_STMT) constructor
{
    initializer = _initializer;
    condition = _condition;
    increment = _increment;
    body = _body;
}

/* Break statement (supports break N for multi-level break) */
function ProgASTBreakStmt(_amount = undefined) : ProgASTNode(PROG_AST.BREAK_STMT) constructor
{
    amount = _amount; /* Expression for number of loops to break (default: 1) */
}

/* Continue statement */
function ProgASTContinueStmt() : ProgASTNode(PROG_AST.CONTINUE_STMT) constructor
{
}

/* Return statement */
function ProgASTReturnStmt(_value) : ProgASTNode(PROG_AST.RETURN_STMT) constructor
{
    value = _value;
}

/* Prefix operation (++i, --i) */
function ProgASTPrefixOp(_op, _target) : ProgASTNode(PROG_AST.PREFIX_OP) constructor
{
    op = _op; /* PROG_TOKEN.PLUS_PLUS or MINUS_MINUS */
    target = _target; /* Must be lvalue (Identifier, Index, Member) */
}

/* Postfix operation (i++, i--) */
function ProgASTPostfixOp(_op, _target) : ProgASTNode(PROG_AST.POSTFIX_OP) constructor
{
    op = _op;
    target = _target;
}

/* Switch statement */
function ProgASTSwitchStmt(_expression, _cases, _default_case) : ProgASTNode(PROG_AST.SWITCH_STMT) constructor
{
    expr = _expression;
    cases = _cases; /* Array of { value, body } */
    default_case = _default_case; /* Block or undefined */
}

/* Function declaration */
function ProgASTFuncDecl(_name, _params, _body, _is_global = false) : ProgASTNode(PROG_AST.FUNC_DECL) constructor
{
    name = _name;
    params = _params; /* Array of { name, default_value } */
    body = _body; /* Block */
    is_global = _is_global;
}

/* Function expression */
function ProgASTFuncExpr(_name, _params, _body) : ProgASTNode(PROG_AST.FUNC_EXPR) constructor
{
    name = _name; /* Optional name (can be undefined/empty) */
    params = _params;
    body = _body;
}

/* For-In statement (for var in collection) */
function ProgASTForInStmt(_variable, _collection, _body, _value_var = undefined, _modifier = undefined) : ProgASTNode(PROG_AST.FOR_IN_STMT) constructor
{
    variable = _variable; /* Identifier string (Key) */
    value_var = _value_var; /* Identifier string (Value, optional) */
    collection = _collection; /* Expression */
    body = _body;
    modifier = _modifier; /* "key" | "value" | undefined */
}

/* Try-Catch statement */
function ProgASTTryStmt(_try_block, _catch_var, _catch_block) : ProgASTNode(PROG_AST.TRY_STMT) constructor
{
    try_block = _try_block;
    catch_var = _catch_var; /* Identifier string for error variable */
    catch_block = _catch_block;
}

/* Destructuring Declaration (var {a, b} = obj) */
function ProgASTDestructuringDecl(_pattern_type, _elements, _initializer) : ProgASTNode(PROG_AST.DESTRUCTURING_DECL) constructor
{
    pattern_type = _pattern_type; 
    elements = _elements; 
    initializer = _initializer; 
}

/* Import Statement */
function ProgASTImportStmt(_imports, _module_path) : ProgASTNode(PROG_AST.IMPORT_STMT) constructor
{
    imports = _imports; /* Array of { name: "exportedName", alias: "localName" } */
    module_path = _module_path; /* String path */
}

/* Export Statement */
function ProgASTExportStmt(_declaration, _is_default = false) : ProgASTNode(PROG_AST.EXPORT_STMT) constructor
{
    declaration = _declaration; /* AST node (VarDecl, FuncDecl, or ClassDecl) */
    is_default = _is_default;
}

/* Throw Statement */
function ProgASTThrowStmt(_expression) : ProgASTNode(PROG_AST.THROW_STMT) constructor
{
    expression = _expression;
}

/* Class declaration */
function ProgASTClassDecl(_name, _super, _members, _constructor) : ProgASTNode(PROG_AST.CLASS_DECL) constructor
{
    name = _name;           /* String: class name */
    super_class = _super;   /* String or undefined: parent class */
    members = _members;     /* Array of {type, name, value, access, is_static} */
    class_constructor = _constructor; /* ProgASTFuncDecl (renamed to avoid keyword conflict if any) */
}

/* New expression (new ClassName(...)) */
function ProgASTNewExpr(_class_name, _args) : ProgASTNode(PROG_AST.NEW_EXPR) constructor
{
    class_name = _class_name; /* Identifier string */
    args = _args;
}

/* This keyword */
function ProgASTThisExpr() : ProgASTNode(PROG_AST.THIS_EXPR) constructor {}

/* Super keyword */
function ProgASTSuperExpr() : ProgASTNode(PROG_AST.SUPER_EXPR) constructor {}

/* Regex literal node (/abc/i) */
function ProgASTRegexLiteral(_pattern, _flags) : ProgASTNode(PROG_AST.REGEX_LITERAL) constructor
{
    pattern = _pattern;
    flags = _flags;
}

/* In expression (x in collection) with optional modifier
   @param _left LHS expression
   @param _right RHS expression (collection)
   @param _modifier "key" | "value" | undefined */
function ProgASTInExpr(_left, _right, _modifier = undefined) : ProgASTNode(PROG_AST.IN_EXPR) constructor
{
    left = _left;
    right = _right;
    modifier = _modifier; /* "key", "value", or undefined */
}

/* Range expression (min..max) */
function ProgASTRangeExpr(_start, _end) : ProgASTNode(PROG_AST.RANGE_EXPR) constructor
{
    range_start = _start;
    range_end = _end;
}

/* Optional member access (obj?.prop) */
function ProgASTOptionalMember(_target, _property) : ProgASTNode(PROG_AST.OPTIONAL_MEMBER) constructor
{
    target = _target;
    property = _property;
}

/* Optional index access (arr?.[idx]) */
function ProgASTOptionalIndex(_target, _index) : ProgASTNode(PROG_AST.OPTIONAL_INDEX) constructor
{
    target = _target;
    index = _index;
}
