/// UI Language AST — ported from UIAST.gml

// ─────────────────────────── Value nodes ───────────────────────────

#[derive(Debug, Clone)]
pub struct UiColor
{
    pub r: u8,
    pub g: u8,
    pub b: u8,
    pub a: f32,
}

#[derive(Debug, Clone)]
pub struct UiProperty
{
    pub key: String,
    pub value: UiValue,
}

// ─────────────────────────── UiValue ───────────────────────────

/// A parsed value expression inside a UI element.
#[derive(Debug, Clone)]
pub enum UiValue
{
    Number(f64),
    Percentage(f64),
    Color(UiColor),
    Str(String),
    Bool(bool),
    Undefined,

    Binding(String),             /* *name */
    ArrayIndex(String, Box<UiValue>), /* *name[idx] */
    LocaKey(String),             /* $"key" */
    ScriptRef(String),           /* @"path" */

    Tuple(Vec<UiValue>),

    Identifier(String),
    Enum(String),

    SpriteDef { name: String, properties: Vec<UiProperty> },
    SurfaceDef { name: String, properties: Vec<UiProperty> },

    BinaryOp { op: String, left: Box<UiValue>, right: Box<UiValue> },
    UnaryOp  { op: String, right: Box<UiValue> },

    FuncCall { func: String, arg: Box<UiValue> },
}

// ─────────────────────────── Element ───────────────────────────

#[derive(Debug, Clone)]
pub struct UiElement
{
    pub element_type: String,
    pub name: String,
    pub properties: Vec<UiProperty>,
    pub children: Vec<UiElement>,
    pub repeat_count: Option<UiValue>,
    pub repeat_var: Option<String>,
}

// ─────────────────────────── Top-level definitions ───────────────────────────

#[derive(Debug, Clone)]
pub enum UiDef
{
    Element(UiElement),
    VarDecl { name: String, value: UiValue },
    ExportVar { name: String, value: UiValue },
    ExportElement(UiElement),
}

#[derive(Debug, Clone)]
pub struct UiDocument
{
    pub definitions: Vec<UiDef>,
}
