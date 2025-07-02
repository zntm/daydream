function control_instance_pause()
{
    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;
    
    obj_Menu_Control_Render.xoffset = -_camera_x;
    obj_Menu_Control_Render.yoffset = -_camera_y;
    
    inst_629EFD9E.x = _camera_x + inst_629EFD9E.xstart;
    inst_629EFD9E.y = _camera_y + inst_629EFD9E.ystart;
    
    inst_13FA255D.x = _camera_x + inst_13FA255D.xstart;
    inst_13FA255D.y = _camera_y + inst_13FA255D.ystart;
    
    inst_7A620B98.x = _camera_x + inst_7A620B98.xstart;
    inst_7A620B98.y = _camera_y + inst_7A620B98.ystart;
    
    inst_284F3DC8.x = _camera_x + inst_284F3DC8.xstart;
    inst_284F3DC8.y = _camera_y + inst_284F3DC8.ystart;
}