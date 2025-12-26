
// AST Node types
enum PROG_AST {
    // Literals
    NUMBER_LITERAL, STRING_LITERAL, BOOL_LITERAL, UNDEFINED_LITERAL,
    ARRAY_LITERAL, OBJECT_LITERAL,
    // Expressions
    IDENTIFIER, BINARY_OP, UNARY_OP, CALL, INDEX, MEMBER,
    ASSIGNMENT, TERNARY, PREFIX_OP, POSTFIX_OP,
    // Statements  
    VAR_DECL, GLOBAL_DECL, IF_STMT, WHILE_STMT, FOR_STMT, REPEAT_STMT,
    BREAK_STMT, CONTINUE_STMT, RETURN_STMT, BLOCK,
    EXPRESSION_STMT, SWITCH_STMT, FUNC_DECL
}

/// @desc Base AST node
function ProgASTNode(_type) constructor {
    type = _type;
    line = 0;
}

/// @desc Binary operation node (e.g. a + b)
function ProgASTBinaryOp(_op, _left, _right) : ProgASTNode(PROG_AST.BINARY_OP) constructor {
    op = _op;
    left = _left;
    right = _right;
}

/// @desc Unary operation node (e.g. -a, !b)
function ProgASTUnaryOp(_op, _right) : ProgASTNode(PROG_AST.UNARY_OP) constructor {
    op = _op;
    right = _right;
}

/// @desc Literal node (number, string, bool)
function ProgASTLiteral(_type, _value) : ProgASTNode(_type) constructor {
    value = _value;
}

/// @desc Array literal node (e.g. [1, 2, 3])
function ProgASTArrayLiteral(_elements) : ProgASTNode(PROG_AST.ARRAY_LITERAL) constructor {
    elements = _elements;
}

/// @desc Object literal node (e.g. {a: 1, b: 2})
function ProgASTObjectLiteral(_pairs) : ProgASTNode(PROG_AST.OBJECT_LITERAL) constructor {
    pairs = _pairs; // Array of {key, value} structs
}

/// @desc Identifier node (variable access)
function ProgASTIdentifier(_name) : ProgASTNode(PROG_AST.IDENTIFIER) constructor {
    name = _name;
}

/// @desc Assignment node (a = b)
function ProgASTAssignment(_target, _value, _op = PROG_TOKEN.ASSIGN) : ProgASTNode(PROG_AST.ASSIGNMENT) constructor {
    target = _target; // Can be Identifier, Index, or Member
    value = _value;
    op = _op; // For +=, -= etc.
}

/// @desc Call node (func(a, b))
function ProgASTCall(_callee, _args) : ProgASTNode(PROG_AST.CALL) constructor {
    callee = _callee;
    args = _args;
}

/// @desc Index access node (arr[i])
function ProgASTIndex(_target, _index) : ProgASTNode(PROG_AST.INDEX) constructor {
    target = _target;
    index = _index;
}

/// @desc Member access node (obj.prop)
function ProgASTMember(_target, _property) : ProgASTNode(PROG_AST.MEMBER) constructor {
    target = _target;
    property = _property; // Identifier string
}

/// @desc Ternary op node (cond ? true : false)
function ProgASTTernary(_condition, _true_branch, _false_branch) : ProgASTNode(PROG_AST.TERNARY) constructor {
    condition = _condition;
    true_branch = _true_branch;
    false_branch = _false_branch;
}

/// @desc Expression statement (wrapper for expressions used as statements)
function ProgASTExpressionStmt(_expression) : ProgASTNode(PROG_AST.EXPRESSION_STMT) constructor {
    expression = _expression;
}

/// @desc Block statement ({ stmt1; stmt2; })
function ProgASTBlock(_statements) : ProgASTNode(PROG_AST.BLOCK) constructor {
    statements = _statements;
}

/// @desc Var declaration (var x = 10)
function ProgASTVarDecl(_name, _initializer) : ProgASTNode(PROG_AST.VAR_DECL) constructor {
    name = _name;
    initializer = _initializer;
}

/// @desc Global declaration (global.x = 10 -> handled as assignment, but this could be 'global var x' if we supported it)
/// For now, GML style global.x is a Member access on 'global' identifier.
/// But 'global var x' is not standard GML. Standard GML is just global.x = value.
/// So we might not need GLOBAL_DECL unless we support 'global x'.
/// Let's support 'global x;' just in case
function ProgASTGlobalDecl(_name) : ProgASTNode(PROG_AST.GLOBAL_DECL) constructor {
    name = _name;
}

/// @desc If statement
function ProgASTIfStmt(_condition, _then_branch, _else_branch) : ProgASTNode(PROG_AST.IF_STMT) constructor {
    condition = _condition;
    then_branch = _then_branch;
    else_branch = _else_branch;
}

/// @desc While statement
function ProgASTWhileStmt(_condition, _body) : ProgASTNode(PROG_AST.WHILE_STMT) constructor {
    condition = _condition;
    body = _body;
}

/// @desc Repeat statement (repeat 5 { ... })
function ProgASTRepeatStmt(_count, _body) : ProgASTNode(PROG_AST.REPEAT_STMT) constructor {
    count = _count;
    body = _body;
}

/// @desc For statement
function ProgASTForStmt(_initializer, _condition, _increment, _body) : ProgASTNode(PROG_AST.FOR_STMT) constructor {
    initializer = _initializer;
    condition = _condition;
    increment = _increment;
    body = _body;
}

/// @desc Break statement
function ProgASTBreakStmt() : ProgASTNode(PROG_AST.BREAK_STMT) constructor {
}

/// @desc Continue statement
function ProgASTContinueStmt() : ProgASTNode(PROG_AST.CONTINUE_STMT) constructor {
}

/// @desc Return statement
function ProgASTReturnStmt(_value) : ProgASTNode(PROG_AST.RETURN_STMT) constructor {
    value = _value;
}

/// @desc Prefix operation (++i, --i)
function ProgASTPrefixOp(_op, _target) : ProgASTNode(PROG_AST.PREFIX_OP) constructor {
    op = _op; // PROG_TOKEN.PLUS_PLUS or MINUS_MINUS
    target = _target; // Must be lvalue (Identifier, Index, Member)
}

/// @desc Postfix operation (i++, i--)
function ProgASTPostfixOp(_op, _target) : ProgASTNode(PROG_AST.POSTFIX_OP) constructor {
    op = _op;
    target = _target;
}

/// @desc Switch statement
function ProgASTSwitchStmt(_expr, _cases, _default_case) : ProgASTNode(PROG_AST.SWITCH_STMT) constructor {
    expr = _expr;
    cases = _cases; // Array of { value, body }
    default_case = _default_case; // Block or undefined
}

/// @desc Function declaration
function ProgASTFuncDecl(_name, _params, _body, _is_global = false) : ProgASTNode(PROG_AST.FUNC_DECL) constructor {
    name = _name;
    params = _params; // Array of parameter names
    body = _body; // Block
    is_global = _is_global;
}
