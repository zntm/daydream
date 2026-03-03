export interface GUIComponentProps {
    x?: number;
    y?: number;
    width?: number;
    height?: number;
    scale?: number; // Optional scale multiplier (default 1.0)
    inventory_name?: string;
    slot_index?: number;
    anchor_x?: string;
    anchor_y?: string;
    icon_sprite?: string;
    icon_index?: number;
}

export interface GUIComponent {
    type: string;
    props: GUIComponentProps;
    children?: GUIComponent[];
}
