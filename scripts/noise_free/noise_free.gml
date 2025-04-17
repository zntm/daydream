function noise_free(_noise)
{
    _noise.__free();
    
    delete _noise;
}