function atla_repair_all()
{
    struct_foreach(global.___atla_page, atla_repair);
}