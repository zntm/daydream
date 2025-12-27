function input_get_gamepad_name(_button)
{
    switch (_button)
    {
        case gp_face1: return "A";
        case gp_face2: return "B";
        case gp_face3: return "X";
        case gp_face4: return "Y";
        case gp_shoulderl: return "LB";
        case gp_shoulderr: return "RB";
        case gp_shoulderlb: return "LT";
        case gp_shoulderrb: return "RT";
        case gp_start: return "Start";
        case gp_select: return "Select";
        case gp_stickl: return "LS";
        case gp_stickr: return "RS";
        case gp_padu: return "D-Pad Up";
        case gp_padd: return "D-Pad Down";
        case gp_padl: return "D-Pad Left";
        case gp_padr: return "D-Pad Right";
        case -1: return "None";
    }
    
    return "Unknown";
}
