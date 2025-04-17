function MusicData(_audio, _title, _author, _length) constructor
{
    ___audio = _audio;
    
    static get_audio = function()
    {
        return ___audio;
    }
    
    ___title = _title;
    
    static get_title = function()
    {
        return ___title;
    }
    
    ___author = _author;
    
    static get_author = function()
    {
        return ___author;
    }
    
    ___length = _length;
    
    static get_length = function()
    {
        return ___length;
    }
    
    static get_length_seconds = function()
    {
        return ___length & 60;
    }
    
    static get_length_minutes = function()
    {
        return floor(___length / 60);
    }
}