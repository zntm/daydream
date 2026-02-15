/// OpenSimplexNoise.gml
/// Functional OpenSimplex Noise implementation for GameMaker
/// Converted from C++ implementation by K.jpg (public domain)

// Constants
#macro OSN_STRETCH_2D -0.211324865405187  // (1/sqrt(2+1)-1)/2
#macro OSN_SQUISH_2D 0.366025403784439    // (sqrt(2+1)-1)/2
#macro OSN_STRETCH_3D -0.16666666666666666 // -1.0 / 6.0
#macro OSN_SQUISH_3D 0.33333333333333333   // 1.0 / 3.0
#macro OSN_STRETCH_4D -0.138196601125011  // (1/sqrt(4+1)-1)/4
#macro OSN_SQUISH_4D 0.309016994374947    // (sqrt(4+1)-1)/4
#macro OSN_NORM_2D 47.0
#macro OSN_NORM_3D 103.0
#macro OSN_NORM_4D 30.0

// Globals
global.__osn_perm = array_create(256, 0);
global.__osn_permGradIndex3d = array_create(256, 0);
global.__osn_gradients2d = [
     5,  2,    2,  5,
    -5,  2,   -2,  5,
     5, -2,    2, -5,
    -5, -2,   -2, -5
];
global.__osn_gradients3d = [
    -11,  4,  4,     -4,  11,  4,    -4,  4,  11,
     11,  4,  4,      4,  11,  4,     4,  4,  11,
    -11, -4,  4,     -4, -11,  4,    -4, -4,  11,
     11, -4,  4,      4, -11,  4,     4, -4,  11,
    -11,  4, -4,     -4,  11, -4,    -4,  4, -11,
     11,  4, -4,      4,  11, -4,     4,  4, -11,
    -11, -4, -4,     -4, -11, -4,    -4, -4, -11,
     11, -4, -4,      4, -11, -4,     4, -4, -11
];
global.__osn_gradients4d = [
     3,  1,  1,  1,      1,  3,  1,  1,      1,  1,  3,  1,      1,  1,  1,  3,
    -3,  1,  1,  1,     -1,  3,  1,  1,     -1,  1,  3,  1,     -1,  1,  1,  3,
     3, -1,  1,  1,      1, -3,  1,  1,      1, -1,  3,  1,      1, -1,  1,  3,
    -3, -1,  1,  1,     -1, -3,  1,  1,     -1, -1,  3,  1,     -1, -1,  1,  3,
     3,  1, -1,  1,      1,  3, -1,  1,      1,  1, -3,  1,      1,  1, -1,  3,
    -3,  1, -1,  1,     -1,  3, -1,  1,     -1,  1, -3,  1,     -1,  1, -1,  3,
     3, -1, -1,  1,      1, -3, -1,  1,      1, -1, -3,  1,      1, -1, -1,  3,
    -3, -1, -1,  1,     -1, -3, -1,  1,     -1, -1, -3,  1,     -1, -1, -1,  3,
     3,  1,  1, -1,      1,  3,  1, -1,      1,  1,  3, -1,      1,  1,  1, -3,
    -3,  1,  1, -1,     -1,  3,  1, -1,     -1,  1,  3, -1,     -1,  1,  1, -3,
     3, -1,  1, -1,      1, -3,  1, -1,      1, -1,  3, -1,      1, -1,  1, -3,
    -3, -1,  1, -1,     -1, -3,  1, -1,     -1, -1,  3, -1,     -1, -1,  1, -3,
     3,  1, -1, -1,      1,  3, -1, -1,      1,  1, -3, -1,      1,  1, -1, -3,
    -3,  1, -1, -1,     -1,  3, -1, -1,     -1,  1, -3, -1,     -1,  1, -1, -3,
     3, -1, -1, -1,      1, -3, -1, -1,      1, -1, -3, -1,      1, -1, -1, -3,
    -3, -1, -1, -1,     -1, -3, -1, -1,     -1, -1, -3, -1,     -1, -1, -1, -3
];

// Initialize with seed
function open_simplex_noise_seed(_seed = 0)
{
    var _source = array_create(256, 0);
    for (var i = 0; i < 256; i++) {
        _source[i] = i;
    }
    
    // Xorshift64* PRNG state initialization
    var _s = (_seed == 0) ? 88172645463325252 : int64(_seed);
    
    // Warm up the generator
    _s = __osn_xorshift64star(_s);
    _s = __osn_xorshift64star(_s);
    _s = __osn_xorshift64star(_s);
    
    for (var i = 255; i >= 0; i--) {
        _s = __osn_xorshift64star(_s);
        var _r = int64(_s) % (i + 1);
        if (_r < 0) _r += (i + 1);
        
        global.__osn_perm[i] = _source[_r];
        global.__osn_permGradIndex3d[i] = (_source[_r] % 24) * 3;
        _source[_r] = _source[i];
    }
}

// Xorshift64* - high quality PRNG using only XOR and shifts
function __osn_xorshift64star(_x)
{
    _x = int64(_x);
    _x = _x ^ (_x << 12);
    _x = _x ^ (_x >> 25);
    _x = _x ^ (_x << 27);
    return int64(_x * 2685821657736338717);
}

// 2D Noise evaluation (Internal)
function __osn_eval2d(_x, _y)
{
    var _stretchOffset = (_x + _y) * OSN_STRETCH_2D;
    var _xs = _x + _stretchOffset;
    var _ys = _y + _stretchOffset;
    
    var _xsb = floor(_xs);
    var _ysb = floor(_ys);
    
    var _squishOffset = (_xsb + _ysb) * OSN_SQUISH_2D;
    var _xb = _xsb + _squishOffset;
    var _yb = _ysb + _squishOffset;
    
    var _xins = _xs - _xsb;
    var _yins = _ys - _ysb;
    
    var _inSum = _xins + _yins;
    
    var _dx0 = _x - _xb;
    var _dy0 = _y - _yb;
    
    var _dx_ext, _dy_ext;
    var _xsv_ext, _ysv_ext;
    var _gi;
    
    var _value = 0;
    
    // Contribution (1,0)
    var _dx1 = _dx0 - 1 - OSN_SQUISH_2D;
    var _dy1 = _dy0 - 0 - OSN_SQUISH_2D;
    var _attn1 = 2 - _dx1 * _dx1 - _dy1 * _dy1;
    if (_attn1 > 0) {
        _attn1 *= _attn1;
        _gi = global.__osn_perm[(global.__osn_perm[(_xsb + 1) & 0xFF] + (_ysb + 0)) & 0xFF] & 0x0E;
        _value += _attn1 * _attn1 * (global.__osn_gradients2d[_gi] * _dx1 + global.__osn_gradients2d[_gi + 1] * _dy1);
    }
    
    // Contribution (0,1)
    var _dx2 = _dx0 - 0 - OSN_SQUISH_2D;
    var _dy2 = _dy0 - 1 - OSN_SQUISH_2D;
    var _attn2 = 2 - _dx2 * _dx2 - _dy2 * _dy2;
    if (_attn2 > 0) {
        _attn2 *= _attn2;
        _gi = global.__osn_perm[(global.__osn_perm[(_xsb + 0) & 0xFF] + (_ysb + 1)) & 0xFF] & 0x0E;
        _value += _attn2 * _attn2 * (global.__osn_gradients2d[_gi] * _dx2 + global.__osn_gradients2d[_gi + 1] * _dy2);
    }
    
    if (_inSum <= 1) {
        // Inside triangle (0,0)
        var _zins = 1 - _inSum;
        if (_zins > _xins || _zins > _yins) {
            if (_xins > _yins) {
                _xsv_ext = _xsb + 1;
                _ysv_ext = _ysb - 1;
                _dx_ext = _dx0 - 1;
                _dy_ext = _dy0 + 1;
            } else {
                _xsv_ext = _xsb - 1;
                _ysv_ext = _ysb + 1;
                _dx_ext = _dx0 + 1;
                _dy_ext = _dy0 - 1;
            }
        } else {
            _xsv_ext = _xsb + 1;
            _ysv_ext = _ysb + 1;
            _dx_ext = _dx0 - 1 - 2 * OSN_SQUISH_2D;
            _dy_ext = _dy0 - 1 - 2 * OSN_SQUISH_2D;
        }
    } else {
        // Inside triangle (1,1)
        var _zins = 2 - _inSum;
        if (_zins < _xins || _zins < _yins) {
            if (_xins > _yins) {
                _xsv_ext = _xsb + 2;
                _ysv_ext = _ysb + 0;
                _dx_ext = _dx0 - 2 - 2 * OSN_SQUISH_2D;
                _dy_ext = _dy0 + 0 - 2 * OSN_SQUISH_2D;
            } else {
                _xsv_ext = _xsb + 0;
                _ysv_ext = _ysb + 2;
                _dx_ext = _dx0 + 0 - 2 * OSN_SQUISH_2D;
                _dy_ext = _dy0 - 2 - 2 * OSN_SQUISH_2D;
            }
        } else {
            _dx_ext = _dx0;
            _dy_ext = _dy0;
            _xsv_ext = _xsb;
            _ysv_ext = _ysb;
        }
        _xsb += 1;
        _ysb += 1;
        _dx0 = _dx0 - 1 - 2 * OSN_SQUISH_2D;
        _dy0 = _dy0 - 1 - 2 * OSN_SQUISH_2D;
    }
    
    // Contribution (0,0) or (1,1)
    var _attn0 = 2 - _dx0 * _dx0 - _dy0 * _dy0;
    if (_attn0 > 0) {
        _attn0 *= _attn0;
        _gi = global.__osn_perm[(global.__osn_perm[_xsb & 0xFF] + _ysb) & 0xFF] & 0x0E;
        _value += _attn0 * _attn0 * (global.__osn_gradients2d[_gi] * _dx0 + global.__osn_gradients2d[_gi + 1] * _dy0);
    }
    
    // Extra vertex
    var _attn_ext = 2 - _dx_ext * _dx_ext - _dy_ext * _dy_ext;
    if (_attn_ext > 0) {
        _attn_ext *= _attn_ext;
        _gi = global.__osn_perm[(global.__osn_perm[_xsv_ext & 0xFF] + _ysv_ext) & 0xFF] & 0x0E;
        _value += _attn_ext * _attn_ext * (global.__osn_gradients2d[_gi] * _dx_ext + global.__osn_gradients2d[_gi + 1] * _dy_ext);
    }
    
    return _value / OSN_NORM_2D;
}

// 3D Noise evaluation (Internal)
function __osn_eval3d(_x, _y, _z)
{
    var _stretchOffset = (_x + _y + _z) * OSN_STRETCH_3D;
    var _xs = _x + _stretchOffset;
    var _ys = _y + _stretchOffset;
    var _zs = _z + _stretchOffset;
    
    var _xsb = floor(_xs);
    var _ysb = floor(_ys);
    var _zsb = floor(_zs);
    
    var _squishOffset = (_xsb + _ysb + _zsb) * OSN_SQUISH_3D;
    var _xb = _xsb + _squishOffset;
    var _yb = _ysb + _squishOffset;
    var _zb = _zsb + _squishOffset;
    
    var _xins = _xs - _xsb;
    var _yins = _ys - _ysb;
    var _zins = _zs - _zsb;
    
    var _inSum = _xins + _yins + _zins;
    
    var _dx0 = _x - _xb;
    var _dy0 = _y - _yb;
    var _dz0 = _z - _zb;
    
    var _dx_ext0, _dy_ext0, _dz_ext0;
    var _dx_ext1, _dy_ext1, _dz_ext1;
    var _xsv_ext0, _ysv_ext0, _zsv_ext0;
    var _xsv_ext1, _ysv_ext1, _zsv_ext1;
    var _gi;
    
    var _value = 0;
    
    if (_inSum <= 1) {
        // Inside tetrahedron (0,0,0)
        var _aPoint = 0x01;
        var _aScore = _xins;
        var _bPoint = 0x02;
        var _bScore = _yins;
        
        if (_aScore >= _bScore && _zins > _bScore) {
            _bScore = _zins;
            _bPoint = 0x04;
        } else if (_aScore < _bScore && _zins > _aScore) {
            _aScore = _zins;
            _aPoint = 0x04;
        }
        
        var _wins = 1 - _inSum;
        if (_wins > _aScore || _wins > _bScore) {
            var _c = (_bScore > _aScore) ? _bPoint : _aPoint;
            
            if ((_c & 0x01) == 0) {
                _xsv_ext0 = _xsb - 1;
                _xsv_ext1 = _xsb;
                _dx_ext0 = _dx0 + 1;
                _dx_ext1 = _dx0;
            } else {
                _xsv_ext0 = _xsb + 1;
                _xsv_ext1 = _xsb + 1;
                _dx_ext0 = _dx0 - 1;
                _dx_ext1 = _dx0 - 1;
            }
            
            if ((_c & 0x02) == 0) {
                _ysv_ext0 = _ysb;
                _ysv_ext1 = _ysb;
                _dy_ext0 = _dy0;
                _dy_ext1 = _dy0;
                if ((_c & 0x01) == 0) {
                    _ysv_ext1 -= 1;
                    _dy_ext1 += 1;
                } else {
                    _ysv_ext0 -= 1;
                    _dy_ext0 += 1;
                }
            } else {
                _ysv_ext0 = _ysb + 1;
                _ysv_ext1 = _ysb + 1;
                _dy_ext0 = _dy0 - 1;
                _dy_ext1 = _dy0 - 1;
            }
            
            if ((_c & 0x04) == 0) {
                _zsv_ext0 = _zsb;
                _zsv_ext1 = _zsb - 1;
                _dz_ext0 = _dz0;
                _dz_ext1 = _dz0 + 1;
            } else {
                _zsv_ext0 = _zsb + 1;
                _zsv_ext1 = _zsb + 1;
                _dz_ext0 = _dz0 - 1;
                _dz_ext1 = _dz0 - 1;
            }
        } else {
            var _c = _aPoint | _bPoint;
            
            if ((_c & 0x01) == 0) {
                _xsv_ext0 = _xsb;
                _xsv_ext1 = _xsb - 1;
                _dx_ext0 = _dx0 - 2 * OSN_SQUISH_3D;
                _dx_ext1 = _dx0 + 1 - OSN_SQUISH_3D;
            } else {
                _xsv_ext0 = _xsb + 1;
                _xsv_ext1 = _xsb + 1;
                _dx_ext0 = _dx0 - 1 - 2 * OSN_SQUISH_3D;
                _dx_ext1 = _dx0 - 1 - OSN_SQUISH_3D;
            }
            
            if ((_c & 0x02) == 0) {
                _ysv_ext0 = _ysb;
                _ysv_ext1 = _ysb - 1;
                _dy_ext0 = _dy0 - 2 * OSN_SQUISH_3D;
                _dy_ext1 = _dy0 + 1 - OSN_SQUISH_3D;
            } else {
                _ysv_ext0 = _ysb + 1;
                _ysv_ext1 = _ysb + 1;
                _dy_ext0 = _dy0 - 1 - 2 * OSN_SQUISH_3D;
                _dy_ext1 = _dy0 - 1 - OSN_SQUISH_3D;
            }
            
            if ((_c & 0x04) == 0) {
                _zsv_ext0 = _zsb;
                _zsv_ext1 = _zsb - 1;
                _dz_ext0 = _dz0 - 2 * OSN_SQUISH_3D;
                _dz_ext1 = _dz0 + 1 - OSN_SQUISH_3D;
            } else {
                _zsv_ext0 = _zsb + 1;
                _zsv_ext1 = _zsb + 1;
                _dz_ext0 = _dz0 - 1 - 2 * OSN_SQUISH_3D;
                _dz_ext1 = _dz0 - 1 - OSN_SQUISH_3D;
            }
        }
        
        // Contribution (0,0,0)
        var _attn0 = 2 - _dx0 * _dx0 - _dy0 * _dy0 - _dz0 * _dz0;
        if (_attn0 > 0) {
            _attn0 *= _attn0;
            _gi = global.__osn_permGradIndex3d[(global.__osn_perm[(global.__osn_perm[(_xsb + 0) & 0xFF] + (_ysb + 0)) & 0xFF] + (_zsb + 0)) & 0xFF];
            _value += _attn0 * _attn0 * (global.__osn_gradients3d[_gi] * _dx0 + global.__osn_gradients3d[_gi + 1] * _dy0 + global.__osn_gradients3d[_gi + 2] * _dz0);
        }
        
        // Contribution (1,0,0)
        var _dx1 = _dx0 - 1 - OSN_SQUISH_3D;
        var _dy1 = _dy0 - 0 - OSN_SQUISH_3D;
        var _dz1 = _dz0 - 0 - OSN_SQUISH_3D;
        var _attn1 = 2 - _dx1 * _dx1 - _dy1 * _dy1 - _dz1 * _dz1;
        if (_attn1 > 0) {
            _attn1 *= _attn1;
            _gi = global.__osn_permGradIndex3d[(global.__osn_perm[(global.__osn_perm[(_xsb + 1) & 0xFF] + (_ysb + 0)) & 0xFF] + (_zsb + 0)) & 0xFF];
            _value += _attn1 * _attn1 * (global.__osn_gradients3d[_gi] * _dx1 + global.__osn_gradients3d[_gi + 1] * _dy1 + global.__osn_gradients3d[_gi + 2] * _dz1);
        }
        
        // Contribution (0,1,0)
        var _dx2 = _dx0 - 0 - OSN_SQUISH_3D;
        var _dy2 = _dy0 - 1 - OSN_SQUISH_3D;
        var _dz2 = _dz1;
        var _attn2 = 2 - _dx2 * _dx2 - _dy2 * _dy2 - _dz2 * _dz2;
        if (_attn2 > 0) {
            _attn2 *= _attn2;
            _gi = global.__osn_permGradIndex3d[(global.__osn_perm[(global.__osn_perm[(_xsb + 0) & 0xFF] + (_ysb + 1)) & 0xFF] + (_zsb + 0)) & 0xFF];
            _value += _attn2 * _attn2 * (global.__osn_gradients3d[_gi] * _dx2 + global.__osn_gradients3d[_gi + 1] * _dy2 + global.__osn_gradients3d[_gi + 2] * _dz2);
        }
        
        // Contribution (0,0,1)
        var _dx3 = _dx2;
        var _dy3 = _dy1;
        var _dz3 = _dz0 - 1 - OSN_SQUISH_3D;
        var _attn3 = 2 - _dx3 * _dx3 - _dy3 * _dy3 - _dz3 * _dz3;
        if (_attn3 > 0) {
            _attn3 *= _attn3;
            _gi = global.__osn_permGradIndex3d[(global.__osn_perm[(global.__osn_perm[(_xsb + 0) & 0xFF] + (_ysb + 0)) & 0xFF] + (_zsb + 1)) & 0xFF];
            _value += _attn3 * _attn3 * (global.__osn_gradients3d[_gi] * _dx3 + global.__osn_gradients3d[_gi + 1] * _dy3 + global.__osn_gradients3d[_gi + 2] * _dz3);
        }
    } else if (_inSum >= 2) {
        // Inside tetrahedron (1,1,1)
        var _aPoint = 0x06;
        var _aScore = _xins;
        var _bPoint = 0x05;
        var _bScore = _yins;
        
        if (_aScore <= _bScore && _zins < _bScore) {
            _bScore = _zins;
            _bPoint = 0x03;
        } else if (_aScore > _bScore && _zins < _aScore) {
            _aScore = _zins;
            _aPoint = 0x03;
        }
        
        var _wins = 3 - _inSum;
        if (_wins < _aScore || _wins < _bScore) {
            var _c = (_bScore < _aScore) ? _bPoint : _aPoint;
            
            if ((_c & 0x01) != 0) {
                _xsv_ext0 = _xsb + 2;
                _xsv_ext1 = _xsb + 1;
                _dx_ext0 = _dx0 - 2 - 3 * OSN_SQUISH_3D;
                _dx_ext1 = _dx0 - 1 - 3 * OSN_SQUISH_3D;
            } else {
                _xsv_ext0 = _xsb;
                _xsv_ext1 = _xsb;
                _dx_ext0 = _dx0 - 3 * OSN_SQUISH_3D;
                _dx_ext1 = _dx0 - 3 * OSN_SQUISH_3D;
            }
            
            if ((_c & 0x02) != 0) {
                _ysv_ext0 = _ysb + 1;
                _ysv_ext1 = _ysb + 1;
                _dy_ext0 = _dy0 - 1 - 3 * OSN_SQUISH_3D;
                _dy_ext1 = _dy0 - 1 - 3 * OSN_SQUISH_3D;
                if ((_c & 0x01) != 0) {
                    _ysv_ext1 += 1;
                    _dy_ext1 -= 1;
                } else {
                    _ysv_ext0 += 1;
                    _dy_ext0 -= 1;
                }
            } else {
                _ysv_ext0 = _ysb;
                _ysv_ext1 = _ysb;
                _dy_ext0 = _dy0 - 3 * OSN_SQUISH_3D;
                _dy_ext1 = _dy0 - 3 * OSN_SQUISH_3D;
            }
            
            if ((_c & 0x04) != 0) {
                _zsv_ext0 = _zsb + 1;
                _zsv_ext1 = _zsb + 2;
                _dz_ext0 = _dz0 - 1 - 3 * OSN_SQUISH_3D;
                _dz_ext1 = _dz0 - 2 - 3 * OSN_SQUISH_3D;
            } else {
                _zsv_ext0 = _zsb;
                _zsv_ext1 = _zsb;
                _dz_ext0 = _dz0 - 3 * OSN_SQUISH_3D;
                _dz_ext1 = _dz0 - 3 * OSN_SQUISH_3D;
            }
        } else {
            var _c = _aPoint & _bPoint;
            
            if ((_c & 0x01) != 0) {
                _xsv_ext0 = _xsb + 1;
                _xsv_ext1 = _xsb + 2;
                _dx_ext0 = _dx0 - 1 - OSN_SQUISH_3D;
                _dx_ext1 = _dx0 - 2 - 2 * OSN_SQUISH_3D;
            } else {
                _xsv_ext0 = _xsb;
                _xsv_ext1 = _xsb;
                _dx_ext0 = _dx0 - OSN_SQUISH_3D;
                _dx_ext1 = _dx0 - 2 * OSN_SQUISH_3D;
            }
            
            if ((_c & 0x02) != 0) {
                _ysv_ext0 = _ysb + 1;
                _ysv_ext1 = _ysb + 2;
                _dy_ext0 = _dy0 - 1 - OSN_SQUISH_3D;
                _dy_ext1 = _dy0 - 2 - 2 * OSN_SQUISH_3D;
            } else {
                _ysv_ext0 = _ysb;
                _ysv_ext1 = _ysb;
                _dy_ext0 = _dy0 - OSN_SQUISH_3D;
                _dy_ext1 = _dy0 - 2 * OSN_SQUISH_3D;
            }
            
            if ((_c & 0x04) != 0) {
                _zsv_ext0 = _zsb + 1;
                _zsv_ext1 = _zsb + 2;
                _dz_ext0 = _dz0 - 1 - OSN_SQUISH_3D;
                _dz_ext1 = _dz0 - 2 - 2 * OSN_SQUISH_3D;
            } else {
                _zsv_ext0 = _zsb;
                _zsv_ext1 = _zsb;
                _dz_ext0 = _dz0 - OSN_SQUISH_3D;
                _dz_ext1 = _dz0 - 2 * OSN_SQUISH_3D;
            }
        }
        
        // Contribution (1,1,0)
        var _dx3 = _dx0 - 1 - 2 * OSN_SQUISH_3D;
        var _dy3 = _dy0 - 1 - 2 * OSN_SQUISH_3D;
        var _dz3 = _dz0 - 0 - 2 * OSN_SQUISH_3D;
        var _attn3 = 2 - _dx3 * _dx3 - _dy3 * _dy3 - _dz3 * _dz3;
        if (_attn3 > 0) {
            _attn3 *= _attn3;
            _gi = global.__osn_permGradIndex3d[(global.__osn_perm[(global.__osn_perm[(_xsb + 1) & 0xFF] + (_ysb + 1)) & 0xFF] + (_zsb + 0)) & 0xFF];
            _value += _attn3 * _attn3 * (global.__osn_gradients3d[_gi] * _dx3 + global.__osn_gradients3d[_gi + 1] * _dy3 + global.__osn_gradients3d[_gi + 2] * _dz3);
        }
        
        // Contribution (1,0,1)
        var _dx2 = _dx3;
        var _dy2 = _dy0 - 0 - 2 * OSN_SQUISH_3D;
        var _dz2 = _dz0 - 1 - 2 * OSN_SQUISH_3D;
        var _attn2 = 2 - _dx2 * _dx2 - _dy2 * _dy2 - _dz2 * _dz2;
        if (_attn2 > 0) {
            _attn2 *= _attn2;
            _gi = global.__osn_permGradIndex3d[(global.__osn_perm[(global.__osn_perm[(_xsb + 1) & 0xFF] + (_ysb + 0)) & 0xFF] + (_zsb + 1)) & 0xFF];
            _value += _attn2 * _attn2 * (global.__osn_gradients3d[_gi] * _dx2 + global.__osn_gradients3d[_gi + 1] * _dy2 + global.__osn_gradients3d[_gi + 2] * _dz2);
        }
        
        // Contribution (0,1,1)
        var _dx1 = _dx0 - 0 - 2 * OSN_SQUISH_3D;
        var _dy1 = _dy3;
        var _dz1 = _dz2;
        var _attn1 = 2 - _dx1 * _dx1 - _dy1 * _dy1 - _dz1 * _dz1;
        if (_attn1 > 0) {
            _attn1 *= _attn1;
            _gi = global.__osn_permGradIndex3d[(global.__osn_perm[(global.__osn_perm[(_xsb + 0) & 0xFF] + (_ysb + 1)) & 0xFF] + (_zsb + 1)) & 0xFF];
            _value += _attn1 * _attn1 * (global.__osn_gradients3d[_gi] * _dx1 + global.__osn_gradients3d[_gi + 1] * _dy1 + global.__osn_gradients3d[_gi + 2] * _dz1);
        }
        
        // Contribution (1,1,1)
        _dx0 = _dx0 - 1 - 3 * OSN_SQUISH_3D;
        _dy0 = _dy0 - 1 - 3 * OSN_SQUISH_3D;
        _dz0 = _dz0 - 1 - 3 * OSN_SQUISH_3D;
        var _attn0 = 2 - _dx0 * _dx0 - _dy0 * _dy0 - _dz0 * _dz0;
        if (_attn0 > 0) {
            _attn0 *= _attn0;
            _gi = global.__osn_permGradIndex3d[(global.__osn_perm[(global.__osn_perm[(_xsb + 1) & 0xFF] + (_ysb + 1)) & 0xFF] + (_zsb + 1)) & 0xFF];
            _value += _attn0 * _attn0 * (global.__osn_gradients3d[_gi] * _dx0 + global.__osn_gradients3d[_gi + 1] * _dy0 + global.__osn_gradients3d[_gi + 2] * _dz0);
        }
    } else {
        // Inside octahedron (rectified 3-simplex)
        var _aScore, _bScore;
        var _aPoint, _bPoint;
        var _aIsFurtherSide, _bIsFurtherSide;
        
        var _p1 = _xins + _yins;
        if (_p1 > 1) {
            _aScore = _p1 - 1;
            _aPoint = 0x03;
            _aIsFurtherSide = true;
        } else {
            _aScore = 1 - _p1;
            _aPoint = 0x04;
            _aIsFurtherSide = false;
        }
        
        var _p2 = _xins + _zins;
        if (_p2 > 1) {
            _bScore = _p2 - 1;
            _bPoint = 0x05;
            _bIsFurtherSide = true;
        } else {
            _bScore = 1 - _p2;
            _bPoint = 0x02;
            _bIsFurtherSide = false;
        }
        
        var _p3 = _yins + _zins;
        if (_p3 > 1) {
            var _score = _p3 - 1;
            if (_aScore <= _bScore && _aScore < _score) {
                _aScore = _score;
                _aPoint = 0x06;
                _aIsFurtherSide = true;
            } else if (_aScore > _bScore && _bScore < _score) {
                _bScore = _score;
                _bPoint = 0x06;
                _bIsFurtherSide = true;
            }
        } else {
            var _score = 1 - _p3;
            if (_aScore <= _bScore && _aScore < _score) {
                _aScore = _score;
                _aPoint = 0x01;
                _aIsFurtherSide = false;
            } else if (_aScore > _bScore && _bScore < _score) {
                _bScore = _score;
                _bPoint = 0x01;
                _bIsFurtherSide = false;
            }
        }
        
        if (_aIsFurtherSide == _bIsFurtherSide) {
            if (_aIsFurtherSide) {
                // Both closest points on (1,1,1) side
                _dx_ext0 = _dx0 - 1 - 3 * OSN_SQUISH_3D;
                _dy_ext0 = _dy0 - 1 - 3 * OSN_SQUISH_3D;
                _dz_ext0 = _dz0 - 1 - 3 * OSN_SQUISH_3D;
                _xsv_ext0 = _xsb + 1;
                _ysv_ext0 = _ysb + 1;
                _zsv_ext0 = _zsb + 1;
                
                var _c = _aPoint & _bPoint;
                if ((_c & 0x01) != 0) {
                    _dx_ext1 = _dx0 - 2 - 2 * OSN_SQUISH_3D;
                    _dy_ext1 = _dy0 - 2 * OSN_SQUISH_3D;
                    _dz_ext1 = _dz0 - 2 * OSN_SQUISH_3D;
                    _xsv_ext1 = _xsb + 2;
                    _ysv_ext1 = _ysb;
                    _zsv_ext1 = _zsb;
                } else if ((_c & 0x02) != 0) {
                    _dx_ext1 = _dx0 - 2 * OSN_SQUISH_3D;
                    _dy_ext1 = _dy0 - 2 - 2 * OSN_SQUISH_3D;
                    _dz_ext1 = _dz0 - 2 * OSN_SQUISH_3D;
                    _xsv_ext1 = _xsb;
                    _ysv_ext1 = _ysb + 2;
                    _zsv_ext1 = _zsb;
                } else {
                    _dx_ext1 = _dx0 - 2 * OSN_SQUISH_3D;
                    _dy_ext1 = _dy0 - 2 * OSN_SQUISH_3D;
                    _dz_ext1 = _dz0 - 2 - 2 * OSN_SQUISH_3D;
                    _xsv_ext1 = _xsb;
                    _ysv_ext1 = _ysb;
                    _zsv_ext1 = _zsb + 2;
                }
            } else {
                // Both closest points on (0,0,0) side
                _dx_ext0 = _dx0;
                _dy_ext0 = _dy0;
                _dz_ext0 = _dz0;
                _xsv_ext0 = _xsb;
                _ysv_ext0 = _ysb;
                _zsv_ext0 = _zsb;
                
                var _c = _aPoint | _bPoint;
                if ((_c & 0x01) == 0) {
                    _dx_ext1 = _dx0 + 1 - OSN_SQUISH_3D;
                    _dy_ext1 = _dy0 - 1 - OSN_SQUISH_3D;
                    _dz_ext1 = _dz0 - 1 - OSN_SQUISH_3D;
                    _xsv_ext1 = _xsb - 1;
                    _ysv_ext1 = _ysb + 1;
                    _zsv_ext1 = _zsb + 1;
                } else if ((_c & 0x02) == 0) {
                    _dx_ext1 = _dx0 - 1 - OSN_SQUISH_3D;
                    _dy_ext1 = _dy0 + 1 - OSN_SQUISH_3D;
                    _dz_ext1 = _dz0 - 1 - OSN_SQUISH_3D;
                    _xsv_ext1 = _xsb + 1;
                    _ysv_ext1 = _ysb - 1;
                    _zsv_ext1 = _zsb + 1;
                } else {
                    _dx_ext1 = _dx0 - 1 - OSN_SQUISH_3D;
                    _dy_ext1 = _dy0 - 1 - OSN_SQUISH_3D;
                    _dz_ext1 = _dz0 + 1 - OSN_SQUISH_3D;
                    _xsv_ext1 = _xsb + 1;
                    _ysv_ext1 = _ysb + 1;
                    _zsv_ext1 = _zsb - 1;
                }
            }
        } else {
            // One point on each side
            var _c1, _c2;
            if (_aIsFurtherSide) {
                _c1 = _aPoint;
                _c2 = _bPoint;
            } else {
                _c1 = _bPoint;
                _c2 = _aPoint;
            }
            
            if ((_c1 & 0x01) == 0) {
                _dx_ext0 = _dx0 + 1 - OSN_SQUISH_3D;
                _dy_ext0 = _dy0 - 1 - OSN_SQUISH_3D;
                _dz_ext0 = _dz0 - 1 - OSN_SQUISH_3D;
                _xsv_ext0 = _xsb - 1;
                _ysv_ext0 = _ysb + 1;
                _zsv_ext0 = _zsb + 1;
            } else if ((_c1 & 0x02) == 0) {
                _dx_ext0 = _dx0 - 1 - OSN_SQUISH_3D;
                _dy_ext0 = _dy0 + 1 - OSN_SQUISH_3D;
                _dz_ext0 = _dz0 - 1 - OSN_SQUISH_3D;
                _xsv_ext0 = _xsb + 1;
                _ysv_ext0 = _ysb - 1;
                _zsv_ext0 = _zsb + 1;
            } else {
                _dx_ext0 = _dx0 - 1 - OSN_SQUISH_3D;
                _dy_ext0 = _dy0 - 1 - OSN_SQUISH_3D;
                _dz_ext0 = _dz0 + 1 - OSN_SQUISH_3D;
                _xsv_ext0 = _xsb + 1;
                _ysv_ext0 = _ysb + 1;
                _zsv_ext0 = _zsb - 1;
            }
            
            _dx_ext1 = _dx0 - 2 * OSN_SQUISH_3D;
            _dy_ext1 = _dy0 - 2 * OSN_SQUISH_3D;
            _dz_ext1 = _dz0 - 2 * OSN_SQUISH_3D;
            _xsv_ext1 = _xsb;
            _ysv_ext1 = _ysb;
            _zsv_ext1 = _zsb;
            if ((_c2 & 0x01) != 0) {
                _dx_ext1 -= 2;
                _xsv_ext1 += 2;
            } else if ((_c2 & 0x02) != 0) {
                _dy_ext1 -= 2;
                _ysv_ext1 += 2;
            } else {
                _dz_ext1 -= 2;
                _zsv_ext1 += 2;
            }
        }
        
        // Contribution (1,0,0)
        var _dx1 = _dx0 - 1 - OSN_SQUISH_3D;
        var _dy1 = _dy0 - 0 - OSN_SQUISH_3D;
        var _dz1 = _dz0 - 0 - OSN_SQUISH_3D;
        var _attn1 = 2 - _dx1 * _dx1 - _dy1 * _dy1 - _dz1 * _dz1;
        if (_attn1 > 0) {
            _attn1 *= _attn1;
            _gi = global.__osn_permGradIndex3d[(global.__osn_perm[(global.__osn_perm[(_xsb + 1) & 0xFF] + (_ysb + 0)) & 0xFF] + (_zsb + 0)) & 0xFF];
            _value += _attn1 * _attn1 * (global.__osn_gradients3d[_gi] * _dx1 + global.__osn_gradients3d[_gi + 1] * _dy1 + global.__osn_gradients3d[_gi + 2] * _dz1);
        }
        
        // Contribution (0,1,0)
        var _dx2 = _dx0 - 0 - OSN_SQUISH_3D;
        var _dy2 = _dy0 - 1 - OSN_SQUISH_3D;
        var _dz2 = _dz1;
        var _attn2 = 2 - _dx2 * _dx2 - _dy2 * _dy2 - _dz2 * _dz2;
        if (_attn2 > 0) {
            _attn2 *= _attn2;
            _gi = global.__osn_permGradIndex3d[(global.__osn_perm[(global.__osn_perm[(_xsb + 0) & 0xFF] + (_ysb + 1)) & 0xFF] + (_zsb + 0)) & 0xFF];
            _value += _attn2 * _attn2 * (global.__osn_gradients3d[_gi] * _dx2 + global.__osn_gradients3d[_gi + 1] * _dy2 + global.__osn_gradients3d[_gi + 2] * _dz2);
        }
        
        // Contribution (0,0,1)
        var _dx3 = _dx2;
        var _dy3 = _dy1;
        var _dz3 = _dz0 - 1 - OSN_SQUISH_3D;
        var _attn3 = 2 - _dx3 * _dx3 - _dy3 * _dy3 - _dz3 * _dz3;
        if (_attn3 > 0) {
            _attn3 *= _attn3;
            _gi = global.__osn_permGradIndex3d[(global.__osn_perm[(global.__osn_perm[(_xsb + 0) & 0xFF] + (_ysb + 0)) & 0xFF] + (_zsb + 1)) & 0xFF];
            _value += _attn3 * _attn3 * (global.__osn_gradients3d[_gi] * _dx3 + global.__osn_gradients3d[_gi + 1] * _dy3 + global.__osn_gradients3d[_gi + 2] * _dz3);
        }
        
        // Contribution (1,1,0)
        var _dx4 = _dx0 - 1 - 2 * OSN_SQUISH_3D;
        var _dy4 = _dy0 - 1 - 2 * OSN_SQUISH_3D;
        var _dz4 = _dz0 - 0 - 2 * OSN_SQUISH_3D;
        var _attn4 = 2 - _dx4 * _dx4 - _dy4 * _dy4 - _dz4 * _dz4;
        if (_attn4 > 0) {
            _attn4 *= _attn4;
            _gi = global.__osn_permGradIndex3d[(global.__osn_perm[(global.__osn_perm[(_xsb + 1) & 0xFF] + (_ysb + 1)) & 0xFF] + (_zsb + 0)) & 0xFF];
            _value += _attn4 * _attn4 * (global.__osn_gradients3d[_gi] * _dx4 + global.__osn_gradients3d[_gi + 1] * _dy4 + global.__osn_gradients3d[_gi + 2] * _dz4);
        }
        
        // Contribution (1,0,1)
        var _dx5 = _dx4;
        var _dy5 = _dy0 - 0 - 2 * OSN_SQUISH_3D;
        var _dz5 = _dz0 - 1 - 2 * OSN_SQUISH_3D;
        var _attn5 = 2 - _dx5 * _dx5 - _dy5 * _dy5 - _dz5 * _dz5;
        if (_attn5 > 0) {
            _attn5 *= _attn5;
            _gi = global.__osn_permGradIndex3d[(global.__osn_perm[(global.__osn_perm[(_xsb + 1) & 0xFF] + (_ysb + 0)) & 0xFF] + (_zsb + 1)) & 0xFF];
            _value += _attn5 * _attn5 * (global.__osn_gradients3d[_gi] * _dx5 + global.__osn_gradients3d[_gi + 1] * _dy5 + global.__osn_gradients3d[_gi + 2] * _dz5);
        }
        
        // Contribution (0,1,1)
        var _dx6 = _dx0 - 0 - 2 * OSN_SQUISH_3D;
        var _dy6 = _dy4;
        var _dz6 = _dz5;
        var _attn6 = 2 - _dx6 * _dx6 - _dy6 * _dy6 - _dz6 * _dz6;
        if (_attn6 > 0) {
            _attn6 *= _attn6;
            _gi = global.__osn_permGradIndex3d[(global.__osn_perm[(global.__osn_perm[(_xsb + 0) & 0xFF] + (_ysb + 1)) & 0xFF] + (_zsb + 1)) & 0xFF];
            _value += _attn6 * _attn6 * (global.__osn_gradients3d[_gi] * _dx6 + global.__osn_gradients3d[_gi + 1] * _dy6 + global.__osn_gradients3d[_gi + 2] * _dz6);
        }
    }
    
    // First extra vertex
    var _attn_ext0 = 2 - _dx_ext0 * _dx_ext0 - _dy_ext0 * _dy_ext0 - _dz_ext0 * _dz_ext0;
    if (_attn_ext0 > 0) {
        _attn_ext0 *= _attn_ext0;
        _gi = global.__osn_permGradIndex3d[(global.__osn_perm[(global.__osn_perm[_xsv_ext0 & 0xFF] + _ysv_ext0) & 0xFF] + _zsv_ext0) & 0xFF];
        _value += _attn_ext0 * _attn_ext0 * (global.__osn_gradients3d[_gi] * _dx_ext0 + global.__osn_gradients3d[_gi + 1] * _dy_ext0 + global.__osn_gradients3d[_gi + 2] * _dz_ext0);
    }
    
    // Second extra vertex
    var _attn_ext1 = 2 - _dx_ext1 * _dx_ext1 - _dy_ext1 * _dy_ext1 - _dz_ext1 * _dz_ext1;
    if (_attn_ext1 > 0) {
        _attn_ext1 *= _attn_ext1;
        _gi = global.__osn_permGradIndex3d[(global.__osn_perm[(global.__osn_perm[_xsv_ext1 & 0xFF] + _ysv_ext1) & 0xFF] + _zsv_ext1) & 0xFF];
        _value += _attn_ext1 * _attn_ext1 * (global.__osn_gradients3d[_gi] * _dx_ext1 + global.__osn_gradients3d[_gi + 1] * _dy_ext1 + global.__osn_gradients3d[_gi + 2] * _dz_ext1);
    }
    
    return _value / OSN_NORM_3D;
}

// 4D Noise evaluation (Internal)
function __osn_eval4d(_x, _y, _z, _w)
{
    var _stretchOffset = (_x + _y + _z + _w) * OSN_STRETCH_4D;
    var _xs = _x + _stretchOffset;
    var _ys = _y + _stretchOffset;
    var _zs = _z + _stretchOffset;
    var _ws = _w + _stretchOffset;
    
    var _xsb = floor(_xs);
    var _ysb = floor(_ys);
    var _zsb = floor(_zs);
    var _wsb = floor(_ws);
    
    var _squishOffset = (_xsb + _ysb + _zsb + _wsb) * OSN_SQUISH_4D;
    var _xb = _xsb + _squishOffset;
    var _yb = _ysb + _squishOffset;
    var _zb = _zsb + _squishOffset;
    var _wb = _wsb + _squishOffset;
    
    var _xins = _xs - _xsb;
    var _yins = _ys - _ysb;
    var _zins = _zs - _zsb;
    var _wins = _ws - _wsb;
    
    var _inSum = _xins + _yins + _zins + _wins;
    
    var _dx0 = _x - _xb;
    var _dy0 = _y - _yb;
    var _dz0 = _z - _zb;
    var _dw0 = _w - _wb;
    
    var _dx_ext0, _dy_ext0, _dz_ext0, _dw_ext0;
    var _dx_ext1, _dy_ext1, _dz_ext1, _dw_ext1;
    var _dx_ext2, _dy_ext2, _dz_ext2, _dw_ext2;
    var _xsv_ext0, _ysv_ext0, _zsv_ext0, _wsv_ext0;
    var _xsv_ext1, _ysv_ext1, _zsv_ext1, _wsv_ext1;
    var _xsv_ext2, _ysv_ext2, _zsv_ext2, _wsv_ext2;
    var _gi;

    var _value = 0;

    if (_inSum <= 1) {
        // Inside pentachoron (0,0,0,0)
        var _aPoint = 0x01;
        var _aScore = _xins;
        var _bPoint = 0x02;
        var _bScore = _yins;
        
        if (_aScore >= _bScore && _zins > _bScore) {
            _bScore = _zins;
            _bPoint = 0x04;
        } else if (_aScore < _bScore && _zins > _aScore) {
            _aScore = _zins;
            _aPoint = 0x04;
        }
        if (_aScore >= _bScore && _wins > _bScore) {
            _bScore = _wins;
            _bPoint = 0x08;
        } else if (_aScore < _bScore && _wins > _aScore) {
            _aScore = _wins;
            _aPoint = 0x08;
        }
        
        var _uins = 1 - _inSum;
        if (_uins > _aScore || _uins > _bScore) {
            var _c = (_bScore > _aScore) ? _bPoint : _aPoint;
            
            if ((_c & 0x01) == 0) {
                _xsv_ext0 = _xsb - 1;
                _xsv_ext1 = _xsb;
                _xsv_ext2 = _xsb;
                _dx_ext0 = _dx0 + 1;
                _dx_ext1 = _dx0;
                _dx_ext2 = _dx0;
            } else {
                _xsv_ext0 = _xsb + 1;
                _xsv_ext1 = _xsb + 1;
                _xsv_ext2 = _xsb + 1;
                _dx_ext0 = _dx0 - 1;
                _dx_ext1 = _dx0 - 1;
                _dx_ext2 = _dx0 - 1;
            }
            
            if ((_c & 0x02) == 0) {
                _ysv_ext0 = _ysb;
                _ysv_ext1 = _ysb;
                _ysv_ext2 = _ysb;
                _dy_ext0 = _dy0;
                _dy_ext1 = _dy0;
                _dy_ext2 = _dy0;
                if ((_c & 0x01) == 0x01) {
                    _ysv_ext0 -= 1;
                    _dy_ext0 += 1;
                } else {
                    _ysv_ext1 -= 1;
                    _dy_ext1 += 1;
                }
            } else {
                _ysv_ext0 = _ysb + 1;
                _ysv_ext1 = _ysb + 1;
                _ysv_ext2 = _ysb + 1;
                _dy_ext0 = _dy0 - 1;
                _dy_ext1 = _dy0 - 1;
                _dy_ext2 = _dy0 - 1;
            }
            
            if ((_c & 0x04) == 0) {
                _zsv_ext0 = _zsb;
                _zsv_ext1 = _zsb;
                _zsv_ext2 = _zsb;
                _dz_ext0 = _dz0;
                _dz_ext1 = _dz0;
                _dz_ext2 = _dz0;
                if ((_c & 0x03) != 0) {
                    if ((_c & 0x03) == 0x03) {
                        _zsv_ext0 -= 1;
                        _dz_ext0 += 1;
                    } else {
                        _zsv_ext1 -= 1;
                        _dz_ext1 += 1;
                    }
                } else {
                    _zsv_ext2 -= 1;
                    _dz_ext2 += 1;
                }
            } else {
                _zsv_ext0 = _zsb + 1;
                _zsv_ext1 = _zsb + 1;
                _zsv_ext2 = _zsb + 1;
                _dz_ext0 = _dz0 - 1;
                _dz_ext1 = _dz0 - 1;
                _dz_ext2 = _dz0 - 1;
            }
            
            if ((_c & 0x08) == 0) {
                _wsv_ext0 = _wsb;
                _wsv_ext1 = _wsb;
                _wsv_ext2 = _wsb - 1;
                _dw_ext0 = _dw0;
                _dw_ext1 = _dw0;
                _dw_ext2 = _dw0 + 1;
            } else {
                _wsv_ext0 = _wsb + 1;
                _wsv_ext1 = _wsb + 1;
                _wsv_ext2 = _wsb + 1;
                _dw_ext0 = _dw0 - 1;
                _dw_ext1 = _dw0 - 1;
                _dw_ext2 = _dw0 - 1;
            }
        } else {
            var _c = _aPoint | _bPoint;
            
            if ((_c & 0x01) == 0) {
                _xsv_ext0 = _xsb;
                _xsv_ext2 = _xsb;
                _xsv_ext1 = _xsb - 1;
                _dx_ext0 = _dx0 - 2 * OSN_SQUISH_4D;
                _dx_ext2 = _dx0 - OSN_SQUISH_4D;
                _dx_ext1 = _dx0 + 1 - OSN_SQUISH_4D;
            } else {
                _xsv_ext0 = _xsb + 1;
                _xsv_ext1 = _xsb + 1;
                _xsv_ext2 = _xsb + 1;
                _dx_ext0 = _dx0 - 1 - 2 * OSN_SQUISH_4D;
                _dx_ext1 = _dx0 - 1 - OSN_SQUISH_4D;
                _dx_ext2 = _dx0 - 1 - OSN_SQUISH_4D;
            }
            
            if ((_c & 0x02) == 0) {
                _ysv_ext0 = _ysb;
                _ysv_ext1 = _ysb;
                _ysv_ext2 = _ysb;
                _dy_ext0 = _dy0 - 2 * OSN_SQUISH_4D;
                _dy_ext1 = _dy0 - OSN_SQUISH_4D;
                _dy_ext2 = _dy0 - OSN_SQUISH_4D;
                if ((_c & 0x01) == 0x01) {
                    _ysv_ext1 -= 1;
                    _dy_ext1 += 1;
                } else {
                    _ysv_ext2 -= 1;
                    _dy_ext2 += 1;
                }
            } else {
                _ysv_ext0 = _ysb + 1;
                _ysv_ext1 = _ysb + 1;
                _ysv_ext2 = _ysb + 1;
                _dy_ext0 = _dy0 - 1 - 2 * OSN_SQUISH_4D;
                _dy_ext1 = _dy0 - 1 - OSN_SQUISH_4D;
                _dy_ext2 = _dy0 - 1 - OSN_SQUISH_4D;
            }
            
            if ((_c & 0x04) == 0) {
                _zsv_ext0 = _zsb;
                _zsv_ext1 = _zsb;
                _zsv_ext2 = _zsb;
                _dz_ext0 = _dz0 - 2 * OSN_SQUISH_4D;
                _dz_ext1 = _dz0 - OSN_SQUISH_4D;
                _dz_ext2 = _dz0 - OSN_SQUISH_4D;
                if ((_c & 0x03) == 0x03) {
                    _zsv_ext1 -= 1;
                    _dz_ext1 += 1;
                } else {
                    _zsv_ext2 -= 1;
                    _dz_ext2 += 1;
                }
            } else {
                _zsv_ext0 = _zsb + 1;
                _zsv_ext1 = _zsb + 1;
                _zsv_ext2 = _zsb + 1;
                _dz_ext0 = _dz0 - 1 - 2 * OSN_SQUISH_4D;
                _dz_ext1 = _dz0 - 1 - OSN_SQUISH_4D;
                _dz_ext2 = _dz0 - 1 - OSN_SQUISH_4D;
            }
            
            if ((_c & 0x08) == 0) {
                _wsv_ext0 = _wsb;
                _wsv_ext1 = _wsb;
                _wsv_ext2 = _wsb - 1;
                _dw_ext0 = _dw0 - 2 * OSN_SQUISH_4D;
                _dw_ext1 = _dw0 - OSN_SQUISH_4D;
                _dw_ext2 = _dw0 + 1 - OSN_SQUISH_4D;
            } else {
                _wsv_ext0 = _wsb + 1;
                _wsv_ext1 = _wsb + 1;
                _wsv_ext2 = _wsb + 1;
                _dw_ext0 = _dw0 - 1 - 2 * OSN_SQUISH_4D;
                _dw_ext1 = _dw0 - 1 - OSN_SQUISH_4D;
                _dw_ext2 = _dw0 - 1 - OSN_SQUISH_4D;
            }
        }
        
        // Contribution (0,0,0,0)
        var _attn0 = 2 - _dx0 * _dx0 - _dy0 * _dy0 - _dz0 * _dz0 - _dw0 * _dw0;
        if (_attn0 > 0) {
            _attn0 *= _attn0;
            _gi = global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(_xsb + 0) & 0xFF] + (_ysb + 0)) & 0xFF] + (_zsb + 0)) & 0xFF] + (_wsb + 0)) & 0xFF] & 0xFC;
            _value += _attn0 * _attn0 * (global.__osn_gradients4d[_gi] * _dx0 + global.__osn_gradients4d[_gi + 1] * _dy0 + global.__osn_gradients4d[_gi + 2] * _dz0 + global.__osn_gradients4d[_gi + 3] * _dw0);
        }
        
        // Contribution (1,0,0,0)
        var _dx1 = _dx0 - 1 - OSN_SQUISH_4D;
        var _dy1 = _dy0 - 0 - OSN_SQUISH_4D;
        var _dz1 = _dz0 - 0 - OSN_SQUISH_4D;
        var _dw1 = _dw0 - 0 - OSN_SQUISH_4D;
        var _attn1 = 2 - _dx1 * _dx1 - _dy1 * _dy1 - _dz1 * _dz1 - _dw1 * _dw1;
        if (_attn1 > 0) {
            _attn1 *= _attn1;
            _gi = global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(_xsb + 1) & 0xFF] + (_ysb + 0)) & 0xFF] + (_zsb + 0)) & 0xFF] + (_wsb + 0)) & 0xFF] & 0xFC;
            _value += _attn1 * _attn1 * (global.__osn_gradients4d[_gi] * _dx1 + global.__osn_gradients4d[_gi + 1] * _dy1 + global.__osn_gradients4d[_gi + 2] * _dz1 + global.__osn_gradients4d[_gi + 3] * _dw1);
        }
        
        // Contribution (0,1,0,0)
        var _dx2 = _dx0 - 0 - OSN_SQUISH_4D;
        var _dy2 = _dy0 - 1 - OSN_SQUISH_4D;
        var _dz2 = _dz1;
        var _dw2 = _dw1;
        var _attn2 = 2 - _dx2 * _dx2 - _dy2 * _dy2 - _dz2 * _dz2 - _dw2 * _dw2;
        if (_attn2 > 0) {
            _attn2 *= _attn2;
            _gi = global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(_xsb + 0) & 0xFF] + (_ysb + 1)) & 0xFF] + (_zsb + 0)) & 0xFF] + (_wsb + 0)) & 0xFF] & 0xFC;
            _value += _attn2 * _attn2 * (global.__osn_gradients4d[_gi] * _dx2 + global.__osn_gradients4d[_gi + 1] * _dy2 + global.__osn_gradients4d[_gi + 2] * _dz2 + global.__osn_gradients4d[_gi + 3] * _dw2);
        }
        
        // Contribution (0,0,1,0)
        var _dx3 = _dx2;
        var _dy3 = _dy1;
        var _dz3 = _dz0 - 1 - OSN_SQUISH_4D;
        var _dw3 = _dw1;
        var _attn3 = 2 - _dx3 * _dx3 - _dy3 * _dy3 - _dz3 * _dz3 - _dw3 * _dw3;
        if (_attn3 > 0) {
            _attn3 *= _attn3;
            _gi = global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(_xsb + 0) & 0xFF] + (_ysb + 0)) & 0xFF] + (_zsb + 1)) & 0xFF] + (_wsb + 0)) & 0xFF] & 0xFC;
            _value += _attn3 * _attn3 * (global.__osn_gradients4d[_gi] * _dx3 + global.__osn_gradients4d[_gi + 1] * _dy3 + global.__osn_gradients4d[_gi + 2] * _dz3 + global.__osn_gradients4d[_gi + 3] * _dw3);
        }
        
        // Contribution (0,0,0,1)
        var _dx4 = _dx2;
        var _dy4 = _dy1;
        var _dz4 = _dz1;
        var _dw4 = _dw0 - 1 - OSN_SQUISH_4D;
        var _attn4 = 2 - _dx4 * _dx4 - _dy4 * _dy4 - _dz4 * _dz4 - _dw4 * _dw4;
        if (_attn4 > 0) {
            _attn4 *= _attn4;
            _gi = global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(_xsb + 0) & 0xFF] + (_ysb + 0)) & 0xFF] + (_zsb + 0)) & 0xFF] + (_wsb + 1)) & 0xFF] & 0xFC;
            _value += _attn4 * _attn4 * (global.__osn_gradients4d[_gi] * _dx4 + global.__osn_gradients4d[_gi + 1] * _dy4 + global.__osn_gradients4d[_gi + 2] * _dz4 + global.__osn_gradients4d[_gi + 3] * _dw4);
        }
    } else {
        if (_inSum >= 3) {
            // Inside pentachoron (1,1,1,1)
            var _aPoint = 0x0E;
            var _aScore = _xins;
            var _bPoint = 0x0D;
            var _bScore = _yins;
            
            if (_aScore <= _bScore && _zins < _bScore) {
                _bScore = _zins;
                _bPoint = 0x0B;
            } else if (_aScore > _bScore && _zins < _aScore) {
                _aScore = _zins;
                _aPoint = 0x0B;
            }
            if (_aScore <= _bScore && _wins < _bScore) {
                _bScore = _wins;
                _bPoint = 0x07;
            } else if (_aScore > _bScore && _wins < _aScore) {
                _aScore = _wins;
                _aPoint = 0x07;
            }
            
            var _uins = 4 - _inSum;
            if (_uins < _aScore || _uins < _bScore) {
                var _c = (_bScore < _aScore) ? _bPoint : _aPoint;
                
                if ((_c & 0x01) != 0) {
                    _xsv_ext0 = _xsb + 2;
                    _xsv_ext1 = _xsb + 1;
                    _xsv_ext2 = _xsb + 1;
                    _dx_ext0 = _dx0 - 2 - 4 * OSN_SQUISH_4D;
                    _dx_ext1 = _dx0 - 1 - 4 * OSN_SQUISH_4D;
                    _dx_ext2 = _dx0 - 1 - 4 * OSN_SQUISH_4D;
                } else {
                    _xsv_ext0 = _xsb;
                    _xsv_ext1 = _xsb;
                    _xsv_ext2 = _xsb;
                    _dx_ext0 = _dx0 - 4 * OSN_SQUISH_4D;
                    _dx_ext1 = _dx0 - 4 * OSN_SQUISH_4D;
                    _dx_ext2 = _dx0 - 4 * OSN_SQUISH_4D;
                }
                
                if ((_c & 0x02) != 0) {
                    _ysv_ext0 = _ysb + 1;
                    _ysv_ext1 = _ysb + 1;
                    _ysv_ext2 = _ysb + 1;
                    _dy_ext0 = _dy0 - 1 - 4 * OSN_SQUISH_4D;
                    _dy_ext1 = _dy0 - 1 - 4 * OSN_SQUISH_4D;
                    _dy_ext2 = _dy0 - 1 - 4 * OSN_SQUISH_4D;
                    if ((_c & 0x01) != 0) {
                        _ysv_ext1 += 1;
                        _dy_ext1 -= 1;
                    } else {
                        _ysv_ext0 += 1;
                        _dy_ext0 -= 1;
                    }
                } else {
                    _ysv_ext0 = _ysb;
                    _ysv_ext1 = _ysb;
                    _ysv_ext2 = _ysb;
                    _dy_ext0 = _dy0 - 4 * OSN_SQUISH_4D;
                    _dy_ext1 = _dy0 - 4 * OSN_SQUISH_4D;
                    _dy_ext2 = _dy0 - 4 * OSN_SQUISH_4D;
                }
                
                if ((_c & 0x04) != 0) {
                    _zsv_ext0 = _zsb + 1;
                    _zsv_ext1 = _zsb + 1;
                    _zsv_ext2 = _zsb + 1;
                    _dz_ext0 = _dz0 - 1 - 4 * OSN_SQUISH_4D;
                    _dz_ext1 = _dz0 - 1 - 4 * OSN_SQUISH_4D;
                    _dz_ext2 = _dz0 - 1 - 4 * OSN_SQUISH_4D;
                    if ((_c & 0x03) != 0x03) {
                        if ((_c & 0x03) == 0) {
                            _zsv_ext0 += 1;
                            _dz_ext0 -= 1;
                        } else {
                            _zsv_ext1 += 1;
                            _dz_ext1 -= 1;
                        }
                    } else {
                        _zsv_ext2 += 1;
                        _dz_ext2 -= 1;
                    }
                } else {
                    _zsv_ext0 = _zsb;
                    _zsv_ext1 = _zsb;
                    _zsv_ext2 = _zsb;
                    _dz_ext0 = _dz0 - 4 * OSN_SQUISH_4D;
                    _dz_ext1 = _dz0 - 4 * OSN_SQUISH_4D;
                    _dz_ext2 = _dz0 - 4 * OSN_SQUISH_4D;
                }
                
                if ((_c & 0x08) != 0) {
                    _wsv_ext0 = _wsb + 1;
                    _wsv_ext1 = _wsb + 1;
                    _wsv_ext2 = _wsb + 2;
                    _dw_ext0 = _dw0 - 1 - 4 * OSN_SQUISH_4D;
                    _dw_ext1 = _dw0 - 1 - 4 * OSN_SQUISH_4D;
                    _dw_ext2 = _dw0 - 2 - 4 * OSN_SQUISH_4D;
                } else {
                    _wsv_ext0 = _wsb;
                    _wsv_ext1 = _wsb;
                    _wsv_ext2 = _wsb;
                    _dw_ext0 = _dw0 - 4 * OSN_SQUISH_4D;
                    _dw_ext1 = _dw0 - 4 * OSN_SQUISH_4D;
                    _dw_ext2 = _dw0 - 4 * OSN_SQUISH_4D;
                }
            } else {
                var _c = _aPoint & _bPoint;
                
                if ((_c & 0x01) != 0) {
                    _xsv_ext0 = _xsb + 1;
                    _xsv_ext2 = _xsb + 1;
                    _xsv_ext1 = _xsb + 2;
                    _dx_ext0 = _dx0 - 1 - 2 * OSN_SQUISH_4D;
                    _dx_ext1 = _dx0 - 2 - 3 * OSN_SQUISH_4D;
                    _dx_ext2 = _dx0 - 1 - 3 * OSN_SQUISH_4D;
                } else {
                    _xsv_ext0 = _xsb;
                    _xsv_ext1 = _xsb;
                    _xsv_ext2 = _xsb;
                    _dx_ext0 = _dx0 - 2 * OSN_SQUISH_4D;
                    _dx_ext1 = _dx0 - 3 * OSN_SQUISH_4D;
                    _dx_ext2 = _dx0 - 3 * OSN_SQUISH_4D;
                }
                
                if ((_c & 0x02) != 0) {
                    _ysv_ext0 = _ysb + 1;
                    _ysv_ext1 = _ysb + 1;
                    _ysv_ext2 = _ysb + 1;
                    _dy_ext0 = _dy0 - 1 - 2 * OSN_SQUISH_4D;
                    _dy_ext1 = _dy0 - 1 - 3 * OSN_SQUISH_4D;
                    _dy_ext2 = _dy0 - 1 - 3 * OSN_SQUISH_4D;
                    if ((_c & 0x01) != 0) {
                        _ysv_ext2 += 1;
                        _dy_ext2 -= 1;
                    } else {
                        _ysv_ext1 += 1;
                        _dy_ext1 -= 1;
                    }
                } else {
                    _ysv_ext0 = _ysb;
                    _ysv_ext1 = _ysb;
                    _ysv_ext2 = _ysb;
                    _dy_ext0 = _dy0 - 2 * OSN_SQUISH_4D;
                    _dy_ext1 = _dy0 - 3 * OSN_SQUISH_4D;
                    _dy_ext2 = _dy0 - 3 * OSN_SQUISH_4D;
                }
                
                if ((_c & 0x04) != 0) {
                    _zsv_ext0 = _zsb + 1;
                    _zsv_ext1 = _zsb + 1;
                    _zsv_ext2 = _zsb + 1;
                    _dz_ext0 = _dz0 - 1 - 2 * OSN_SQUISH_4D;
                    _dz_ext1 = _dz0 - 1 - 3 * OSN_SQUISH_4D;
                    _dz_ext2 = _dz0 - 1 - 3 * OSN_SQUISH_4D;
                    if ((_c & 0x03) != 0) {
                        _zsv_ext2 += 1;
                        _dz_ext2 -= 1;
                    } else {
                        _zsv_ext1 += 1;
                        _dz_ext1 -= 1;
                    }
                } else {
                    _zsv_ext0 = _zsb;
                    _zsv_ext1 = _zsb;
                    _zsv_ext2 = _zsb;
                    _dz_ext0 = _dz0 - 2 * OSN_SQUISH_4D;
                    _dz_ext1 = _dz0 - 3 * OSN_SQUISH_4D;
                    _dz_ext2 = _dz0 - 3 * OSN_SQUISH_4D;
                }
                
                if ((_c & 0x08) != 0) {
                    _wsv_ext0 = _wsb + 1;
                    _wsv_ext1 = _wsb + 1;
                    _wsv_ext2 = _wsb + 2;
                    _dw_ext0 = _dw0 - 1 - 2 * OSN_SQUISH_4D;
                    _dw_ext1 = _dw0 - 1 - 3 * OSN_SQUISH_4D;
                    _dw_ext2 = _dw0 - 2 - 3 * OSN_SQUISH_4D;
                } else {
                    _wsv_ext0 = _wsb;
                    _wsv_ext1 = _wsb;
                    _wsv_ext2 = _wsb;
                    _dw_ext0 = _dw0 - 2 * OSN_SQUISH_4D;
                    _dw_ext1 = _dw0 - 3 * OSN_SQUISH_4D;
                    _dw_ext2 = _dw0 - 3 * OSN_SQUISH_4D;
                }
            }
            
            // Contribution (1,1,1,0)
            var _dx4 = _dx0 - 1 - 3 * OSN_SQUISH_4D;
            var _dy4 = _dy0 - 1 - 3 * OSN_SQUISH_4D;
            var _dz4 = _dz0 - 1 - 3 * OSN_SQUISH_4D;
            var _dw4 = _dw0 - 3 * OSN_SQUISH_4D;
            var _attn4 = 2 - _dx4 * _dx4 - _dy4 * _dy4 - _dz4 * _dz4 - _dw4 * _dw4;
            if (_attn4 > 0) {
                _attn4 *= _attn4;
                _gi = global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(_xsb + 1) & 0xFF] + (_ysb + 1)) & 0xFF] + (_zsb + 1)) & 0xFF] + (_wsb + 0)) & 0xFF] & 0xFC;
            _value += _attn4 * _attn4 * (global.__osn_gradients4d[_gi] * _dx4 + global.__osn_gradients4d[_gi + 1] * _dy4 + global.__osn_gradients4d[_gi + 2] * _dz4 + global.__osn_gradients4d[_gi + 3] * _dw4);
            }
            
            // Contribution (1,1,0,1)
            var _dx3 = _dx4;
            var _dy3 = _dy4;
            var _dz3 = _dz0 - 3 * OSN_SQUISH_4D;
            var _dw3 = _dw0 - 1 - 3 * OSN_SQUISH_4D;
            var _attn3 = 2 - _dx3 * _dx3 - _dy3 * _dy3 - _dz3 * _dz3 - _dw3 * _dw3;
            if (_attn3 > 0) {
                _attn3 *= _attn3;
                _gi = global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(_xsb + 1) & 0xFF] + (_ysb + 1)) & 0xFF] + (_zsb + 0)) & 0xFF] + (_wsb + 1)) & 0xFF] & 0xFC;
            _value += _attn3 * _attn3 * (global.__osn_gradients4d[_gi] * _dx3 + global.__osn_gradients4d[_gi + 1] * _dy3 + global.__osn_gradients4d[_gi + 2] * _dz3 + global.__osn_gradients4d[_gi + 3] * _dw3);
            }
            
            // Contribution (1,0,1,1)
            var _dx2 = _dx4;
            var _dy2 = _dy0 - 3 * OSN_SQUISH_4D;
            var _dz2 = _dz4;
            var _dw2 = _dw3;
            var _attn2 = 2 - _dx2 * _dx2 - _dy2 * _dy2 - _dz2 * _dz2 - _dw2 * _dw2;
            if (_attn2 > 0) {
                _attn2 *= _attn2;
                _gi = global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(_xsb + 1) & 0xFF] + (_ysb + 0)) & 0xFF] + (_zsb + 1)) & 0xFF] + (_wsb + 1)) & 0xFF] & 0xFC;
            _value += _attn2 * _attn2 * (global.__osn_gradients4d[_gi] * _dx2 + global.__osn_gradients4d[_gi + 1] * _dy2 + global.__osn_gradients4d[_gi + 2] * _dz2 + global.__osn_gradients4d[_gi + 3] * _dw2);
            }
            
            // Contribution (0,1,1,1)
            var _dx1 = _dx0 - 3 * OSN_SQUISH_4D;
            var _dz1 = _dz4;
            var _dy1 = _dy4;
            var _dw1 = _dw3;
            var _attn1 = 2 - _dx1 * _dx1 - _dy1 * _dy1 - _dz1 * _dz1 - _dw1 * _dw1;
            if (_attn1 > 0) {
                _attn1 *= _attn1;
                _gi = global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(_xsb + 0) & 0xFF] + (_ysb + 1)) & 0xFF] + (_zsb + 1)) & 0xFF] + (_wsb + 1)) & 0xFF] & 0xFC;
            _value += _attn1 * _attn1 * (global.__osn_gradients4d[_gi] * _dx1 + global.__osn_gradients4d[_gi + 1] * _dy1 + global.__osn_gradients4d[_gi + 2] * _dz1 + global.__osn_gradients4d[_gi + 3] * _dw1);
            }
            
            // Contribution (1,1,1,1)
            _dx0 = _dx0 - 1 - 4 * OSN_SQUISH_4D;
            _dy0 = _dy0 - 1 - 4 * OSN_SQUISH_4D;
            _dz0 = _dz0 - 1 - 4 * OSN_SQUISH_4D;
            _dw0 = _dw0 - 1 - 4 * OSN_SQUISH_4D;
            var _attn0 = 2 - _dx0 * _dx0 - _dy0 * _dy0 - _dz0 * _dz0 - _dw0 * _dw0;
            if (_attn0 > 0) {
                _attn0 *= _attn0;
                _gi = global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(_xsb + 1) & 0xFF] + (_ysb + 1)) & 0xFF] + (_zsb + 1)) & 0xFF] + (_wsb + 1)) & 0xFF] & 0xFC;
            _value += _attn0 * _attn0 * (global.__osn_gradients4d[_gi] * _dx0 + global.__osn_gradients4d[_gi + 1] * _dy0 + global.__osn_gradients4d[_gi + 2] * _dz0 + global.__osn_gradients4d[_gi + 3] * _dw0);
            }
        } else {
            // Inside hexadecachoron
            var _aScore, _bScore;
            var _aPoint, _bPoint;
            var _aIsFurtherSide, _bIsFurtherSide;
            
            var _p1 = _xins + _yins;
            var _p2 = _xins + _zins;
            var _p3 = _xins + _wins;
            var _p4 = _yins + _zins;
            var _p5 = _yins + _wins;
            var _p6 = _zins + _wins;
            
            if (_p1 > 1) {
                _aScore = _p1 - 1;
                _aPoint = 0x03;
                _aIsFurtherSide = true;
            } else {
                _aScore = 1 - _p1;
                _aPoint = 0x0C;
                _aIsFurtherSide = false;
            }
            
            if (_p2 > 1) {
                _bScore = _p2 - 1;
                _bPoint = 0x05;
                _bIsFurtherSide = true;
            } else {
                _bScore = 1 - _p2;
                _bPoint = 0x0A;
                _bIsFurtherSide = false;
            }
            
            if (_p3 > 1) {
                var _score = _p3 - 1;
                if (_aScore <= _bScore && _aScore < _score) {
                    _aScore = _score;
                    _aPoint = 0x09;
                    _aIsFurtherSide = true;
                } else if (_aScore > _bScore && _bScore < _score) {
                    _bScore = _score;
                    _bPoint = 0x09;
                    _bIsFurtherSide = true;
                }
            } else {
                var _score = 1 - _p3;
                if (_aScore <= _bScore && _aScore < _score) {
                    _aScore = _score;
                    _aPoint = 0x06;
                    _aIsFurtherSide = false;
                } else if (_aScore > _bScore && _bScore < _score) {
                    _bScore = _score;
                    _bPoint = 0x06;
                    _bIsFurtherSide = false;
                }
            }
            
            if (_p4 > 1) {
                var _score = _p4 - 1;
                if (_aScore <= _bScore && _aScore < _score) {
                    _aScore = _score;
                    _aPoint = 0x06;
                    _aIsFurtherSide = true;
                } else if (_aScore > _bScore && _bScore < _score) {
                    _bScore = _score;
                    _bPoint = 0x06;
                    _bIsFurtherSide = true;
                }
            } else {
                var _score = 1 - _p4;
                if (_aScore <= _bScore && _aScore < _score) {
                    _aScore = _score;
                    _aPoint = 0x09;
                    _aIsFurtherSide = false;
                } else if (_aScore > _bScore && _bScore < _score) {
                    _bScore = _score;
                    _bPoint = 0x09;
                    _bIsFurtherSide = false;
                }
            }
            
            if (_p5 > 1) {
                var _score = _p5 - 1;
                if (_aScore <= _bScore && _aScore < _score) {
                    _aScore = _score;
                    _aPoint = 0x0A;
                    _aIsFurtherSide = true;
                } else if (_aScore > _bScore && _bScore < _score) {
                    _bScore = _score;
                    _bPoint = 0x0A;
                    _bIsFurtherSide = true;
                }
            } else {
                var _score = 1 - _p5;
                if (_aScore <= _bScore && _aScore < _score) {
                    _aScore = _score;
                    _aPoint = 0x05;
                    _aIsFurtherSide = false;
                } else if (_aScore > _bScore && _bScore < _score) {
                    _bScore = _score;
                    _bPoint = 0x05;
                    _bIsFurtherSide = false;
                }
            }
            
            if (_p6 > 1) {
                var _score = _p6 - 1;
                if (_aScore <= _bScore && _aScore < _score) {
                    _aScore = _score;
                    _aPoint = 0x0C;
                    _aIsFurtherSide = true;
                } else if (_aScore > _bScore && _bScore < _score) {
                    _bScore = _score;
                    _bPoint = 0x0C;
                    _bIsFurtherSide = true;
                }
            } else {
                var _score = 1 - _p6;
                if (_aScore <= _bScore && _aScore < _score) {
                    _aScore = _score;
                    _aPoint = 0x03;
                    _aIsFurtherSide = false;
                } else if (_aScore > _bScore && _bScore < _score) {
                    _bScore = _score;
                    _bPoint = 0x03;
                    _bIsFurtherSide = false;
                }
            }
            
            if (_aIsFurtherSide == _bIsFurtherSide) {
                if (_aIsFurtherSide) {
                    // Both closest points on (2,2,2,2) side
                    _dx_ext0 = _dx0 - 1 - 4 * OSN_SQUISH_4D;
                    _dy_ext0 = _dy0 - 1 - 4 * OSN_SQUISH_4D;
                    _dz_ext0 = _dz0 - 1 - 4 * OSN_SQUISH_4D;
                    _dw_ext0 = _dw0 - 1 - 4 * OSN_SQUISH_4D;
                    _xsv_ext0 = _xsb + 1;
                    _ysv_ext0 = _ysb + 1;
                    _zsv_ext0 = _zsb + 1;
                    _wsv_ext0 = _wsb + 1;
                    
                    var _c = _aPoint & _bPoint;
                    if ((_c & 0x01) != 0) {
                        _dx_ext1 = _dx0 - 2 - 3 * OSN_SQUISH_4D;
                        _dy_ext1 = _dy0 - 3 * OSN_SQUISH_4D;
                        _dz_ext1 = _dz0 - 3 * OSN_SQUISH_4D;
                        _dw_ext1 = _dw0 - 3 * OSN_SQUISH_4D;
                        _xsv_ext1 = _xsb + 2;
                        _ysv_ext1 = _ysb;
                        _zsv_ext1 = _zsb;
                        _wsv_ext1 = _wsb;
                    } else if ((_c & 0x02) != 0) {
                        _dx_ext1 = _dx0 - 3 * OSN_SQUISH_4D;
                        _dy_ext1 = _dy0 - 2 - 3 * OSN_SQUISH_4D;
                        _dz_ext1 = _dz0 - 3 * OSN_SQUISH_4D;
                        _dw_ext1 = _dw0 - 3 * OSN_SQUISH_4D;
                        _xsv_ext1 = _xsb;
                        _ysv_ext1 = _ysb + 2;
                        _zsv_ext1 = _zsb;
                        _wsv_ext1 = _wsb;
                    } else if ((_c & 0x04) != 0) {
                        _dx_ext1 = _dx0 - 3 * OSN_SQUISH_4D;
                        _dy_ext1 = _dy0 - 3 * OSN_SQUISH_4D;
                        _dz_ext1 = _dz0 - 2 - 3 * OSN_SQUISH_4D;
                        _dw_ext1 = _dw0 - 3 * OSN_SQUISH_4D;
                        _xsv_ext1 = _xsb;
                        _ysv_ext1 = _ysb;
                        _zsv_ext1 = _zsb + 2;
                        _wsv_ext1 = _wsb;
                    } else {
                        _dx_ext1 = _dx0 - 3 * OSN_SQUISH_4D;
                        _dy_ext1 = _dy0 - 3 * OSN_SQUISH_4D;
                        _dz_ext1 = _dz0 - 3 * OSN_SQUISH_4D;
                        _dw_ext1 = _dw0 - 2 - 3 * OSN_SQUISH_4D;
                        _xsv_ext1 = _xsb;
                        _ysv_ext1 = _ysb;
                        _zsv_ext1 = _zsb;
                        _wsv_ext1 = _wsb + 2;
                    }
                } else {
                    // Both closest points on (0,0,0,0) side
                    _dx_ext0 = _dx0;
                    _dy_ext0 = _dy0;
                    _dz_ext0 = _dz0;
                    _dw_ext0 = _dw0;
                    _xsv_ext0 = _xsb;
                    _ysv_ext0 = _ysb;
                    _zsv_ext0 = _zsb;
                    _wsv_ext0 = _wsb;
                    
                    var _c = _aPoint | _bPoint;
                    if ((_c & 0x01) == 0) {
                        _dx_ext1 = _dx0 + 1 - OSN_SQUISH_4D;
                        _dy_ext1 = _dy0 - 1 - OSN_SQUISH_4D;
                        _dz_ext1 = _dz0 - 1 - OSN_SQUISH_4D;
                        _dw_ext1 = _dw0 - 1 - OSN_SQUISH_4D;
                        _xsv_ext1 = _xsb - 1;
                        _ysv_ext1 = _ysb + 1;
                        _zsv_ext1 = _zsb + 1;
                        _wsv_ext1 = _wsb + 1;
                    } else if ((_c & 0x02) == 0) {
                        _dx_ext1 = _dx0 - 1 - OSN_SQUISH_4D;
                        _dy_ext1 = _dy0 + 1 - OSN_SQUISH_4D;
                        _dz_ext1 = _dz0 - 1 - OSN_SQUISH_4D;
                        _dw_ext1 = _dw0 - 1 - OSN_SQUISH_4D;
                        _xsv_ext1 = _xsb + 1;
                        _ysv_ext1 = _ysb - 1;
                        _zsv_ext1 = _zsb + 1;
                        _wsv_ext1 = _wsb + 1;
                    } else if ((_c & 0x04) == 0) {
                        _dx_ext1 = _dx0 - 1 - OSN_SQUISH_4D;
                        _dy_ext1 = _dy0 - 1 - OSN_SQUISH_4D;
                        _dz_ext1 = _dz0 + 1 - OSN_SQUISH_4D;
                        _dw_ext1 = _dw0 - 1 - OSN_SQUISH_4D;
                        _xsv_ext1 = _xsb + 1;
                        _ysv_ext1 = _ysb + 1;
                        _zsv_ext1 = _zsb - 1;
                        _wsv_ext1 = _wsb + 1;
                    } else {
                        _dx_ext1 = _dx0 - 1 - OSN_SQUISH_4D;
                        _dy_ext1 = _dy0 - 1 - OSN_SQUISH_4D;
                        _dz_ext1 = _dz0 - 1 - OSN_SQUISH_4D;
                        _dw_ext1 = _dw0 + 1 - OSN_SQUISH_4D;
                        _xsv_ext1 = _xsb + 1;
                        _ysv_ext1 = _ysb + 1;
                        _zsv_ext1 = _zsb + 1;
                        _wsv_ext1 = _wsb - 1;
                    }
                }
            } else {
                // One point on each side
                var _c1, _c2;
                if (_aIsFurtherSide) {
                    _c1 = _aPoint;
                    _c2 = _bPoint;
                } else {
                    _c1 = _bPoint;
                    _c2 = _aPoint;
                }
                
                if ((_c1 & 0x01) == 0) {
                    _dx_ext0 = _dx0 + 1 - OSN_SQUISH_4D;
                    _dy_ext0 = _dy0 - 1 - OSN_SQUISH_4D;
                    _dz_ext0 = _dz0 - 1 - OSN_SQUISH_4D;
                    _dw_ext0 = _dw0 - 1 - OSN_SQUISH_4D;
                    _xsv_ext0 = _xsb - 1;
                    _ysv_ext0 = _ysb + 1;
                    _zsv_ext0 = _zsb + 1;
                    _wsv_ext0 = _wsb + 1;
                } else if ((_c1 & 0x02) == 0) {
                    _dx_ext0 = _dx0 - 1 - OSN_SQUISH_4D;
                    _dy_ext0 = _dy0 + 1 - OSN_SQUISH_4D;
                    _dz_ext0 = _dz0 - 1 - OSN_SQUISH_4D;
                    _dw_ext0 = _dw0 - 1 - OSN_SQUISH_4D;
                    _xsv_ext0 = _xsb + 1;
                    _ysv_ext0 = _ysb - 1;
                    _zsv_ext0 = _zsb + 1;
                    _wsv_ext0 = _wsb + 1;
                } else if ((_c1 & 0x04) == 0) {
                    _dx_ext0 = _dx0 - 1 - OSN_SQUISH_4D;
                    _dy_ext0 = _dy0 - 1 - OSN_SQUISH_4D;
                    _dz_ext0 = _dz0 + 1 - OSN_SQUISH_4D;
                    _dw_ext0 = _dw0 - 1 - OSN_SQUISH_4D;
                    _xsv_ext0 = _xsb + 1;
                    _ysv_ext0 = _ysb + 1;
                    _zsv_ext0 = _zsb - 1;
                    _wsv_ext0 = _wsb + 1;
                } else {
                    _dx_ext0 = _dx0 - 1 - OSN_SQUISH_4D;
                    _dy_ext0 = _dy0 - 1 - OSN_SQUISH_4D;
                    _dz_ext0 = _dz0 - 1 - OSN_SQUISH_4D;
                    _dw_ext0 = _dw0 + 1 - OSN_SQUISH_4D;
                    _xsv_ext0 = _xsb + 1;
                    _ysv_ext0 = _ysb + 1;
                    _zsv_ext0 = _zsb + 1;
                    _wsv_ext0 = _wsb - 1;
                }
                
                _dx_ext1 = _dx0 - 2 * OSN_SQUISH_4D;
                _dy_ext1 = _dy0 - 2 * OSN_SQUISH_4D;
                _dz_ext1 = _dz0 - 2 * OSN_SQUISH_4D;
                _dw_ext1 = _dw0 - 2 * OSN_SQUISH_4D;
                _xsv_ext1 = _xsb;
                _ysv_ext1 = _ysb;
                _zsv_ext1 = _zsb;
                _wsv_ext1 = _wsb;
                if ((_c2 & 0x01) != 0) {
                    _dx_ext1 -= 2;
                    _xsv_ext1 += 2;
                } else if ((_c2 & 0x02) != 0) {
                    _dy_ext1 -= 2;
                    _ysv_ext1 += 2;
                } else if ((_c2 & 0x04) != 0) {
                    _dz_ext1 -= 2;
                    _zsv_ext1 += 2;
                } else {
                    _dw_ext1 -= 2;
                    _wsv_ext1 += 2;
                }
            }
            
            // Contribution (1,0,0,0)
            var _dx1 = _dx0 - 1 - OSN_SQUISH_4D;
            var _dy1 = _dy0 - 0 - OSN_SQUISH_4D;
            var _dz1 = _dz0 - 0 - OSN_SQUISH_4D;
            var _dw1 = _dw0 - 0 - OSN_SQUISH_4D;
            var _attn1 = 2 - _dx1 * _dx1 - _dy1 * _dy1 - _dz1 * _dz1 - _dw1 * _dw1;
            if (_attn1 > 0) {
                _attn1 *= _attn1;
                _gi = global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(_xsb + 1) & 0xFF] + (_ysb + 0)) & 0xFF] + (_zsb + 0)) & 0xFF] + (_wsb + 0)) & 0xFF] & 0xFC;
            _value += _attn1 * _attn1 * (global.__osn_gradients4d[_gi] * _dx1 + global.__osn_gradients4d[_gi + 1] * _dy1 + global.__osn_gradients4d[_gi + 2] * _dz1 + global.__osn_gradients4d[_gi + 3] * _dw1);
            }
            
            // Contribution (0,1,0,0)
            var _dx2 = _dx0 - 0 - OSN_SQUISH_4D;
            var _dy2 = _dy0 - 1 - OSN_SQUISH_4D;
            var _dz2 = _dz1;
            var _dw2 = _dw1;
            var _attn2 = 2 - _dx2 * _dx2 - _dy2 * _dy2 - _dz2 * _dz2 - _dw2 * _dw2;
            if (_attn2 > 0) {
                _attn2 *= _attn2;
                _gi = global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(_xsb + 0) & 0xFF] + (_ysb + 1)) & 0xFF] + (_zsb + 0)) & 0xFF] + (_wsb + 0)) & 0xFF] & 0xFC;
            _value += _attn2 * _attn2 * (global.__osn_gradients4d[_gi] * _dx2 + global.__osn_gradients4d[_gi + 1] * _dy2 + global.__osn_gradients4d[_gi + 2] * _dz2 + global.__osn_gradients4d[_gi + 3] * _dw2);
            }
            
            // Contribution (0,0,1,0)
            var _dx3 = _dx2;
            var _dy3 = _dy1;
            var _dz3 = _dz0 - 1 - OSN_SQUISH_4D;
            var _dw3 = _dw1;
            var _attn3 = 2 - _dx3 * _dx3 - _dy3 * _dy3 - _dz3 * _dz3 - _dw3 * _dw3;
            if (_attn3 > 0) {
                _attn3 *= _attn3;
                _gi = global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(_xsb + 0) & 0xFF] + (_ysb + 0)) & 0xFF] + (_zsb + 1)) & 0xFF] + (_wsb + 0)) & 0xFF] & 0xFC;
            _value += _attn3 * _attn3 * (global.__osn_gradients4d[_gi] * _dx3 + global.__osn_gradients4d[_gi + 1] * _dy3 + global.__osn_gradients4d[_gi + 2] * _dz3 + global.__osn_gradients4d[_gi + 3] * _dw3);
            }
            
            // Contribution (0,0,0,1)
            var _dx4 = _dx2;
            var _dy4 = _dy1;
            var _dz4 = _dz1;
            var _dw4 = _dw0 - 1 - OSN_SQUISH_4D;
            var _attn4 = 2 - _dx4 * _dx4 - _dy4 * _dy4 - _dz4 * _dz4 - _dw4 * _dw4;
            if (_attn4 > 0) {
                _attn4 *= _attn4;
                _gi = global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(_xsb + 0) & 0xFF] + (_ysb + 0)) & 0xFF] + (_zsb + 0)) & 0xFF] + (_wsb + 1)) & 0xFF] & 0xFC;
            _value += _attn4 * _attn4 * (global.__osn_gradients4d[_gi] * _dx4 + global.__osn_gradients4d[_gi + 1] * _dy4 + global.__osn_gradients4d[_gi + 2] * _dz4 + global.__osn_gradients4d[_gi + 3] * _dw4);
            }
            
            // Contribution (1,1,0,0)
            var _dx5 = _dx0 - 1 - 2 * OSN_SQUISH_4D;
            var _dy5 = _dy0 - 1 - 2 * OSN_SQUISH_4D;
            var _dz5 = _dz0 - 0 - 2 * OSN_SQUISH_4D;
            var _dw5 = _dw0 - 0 - 2 * OSN_SQUISH_4D;
            var _attn5 = 2 - _dx5 * _dx5 - _dy5 * _dy5 - _dz5 * _dz5 - _dw5 * _dw5;
            if (_attn5 > 0) {
                _attn5 *= _attn5;
                _gi = global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(_xsb + 1) & 0xFF] + (_ysb + 1)) & 0xFF] + (_zsb + 0)) & 0xFF] + (_wsb + 0)) & 0xFF] & 0xFC;
            _value += _attn5 * _attn5 * (global.__osn_gradients4d[_gi] * _dx5 + global.__osn_gradients4d[_gi + 1] * _dy5 + global.__osn_gradients4d[_gi + 2] * _dz5 + global.__osn_gradients4d[_gi + 3] * _dw5);
            }
            
            // Contribution (1,0,1,0)
            var _dx6 = _dx0 - 1 - 2 * OSN_SQUISH_4D;
            var _dy6 = _dy0 - 0 - 2 * OSN_SQUISH_4D;
            var _dz6 = _dz0 - 1 - 2 * OSN_SQUISH_4D;
            var _dw6 = _dw0 - 0 - 2 * OSN_SQUISH_4D;
            var _attn6 = 2 - _dx6 * _dx6 - _dy6 * _dy6 - _dz6 * _dz6 - _dw6 * _dw6;
            if (_attn6 > 0) {
                _attn6 *= _attn6;
                _gi = global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(_xsb + 1) & 0xFF] + (_ysb + 0)) & 0xFF] + (_zsb + 1)) & 0xFF] + (_wsb + 0)) & 0xFF] & 0xFC;
            _value += _attn6 * _attn6 * (global.__osn_gradients4d[_gi] * _dx6 + global.__osn_gradients4d[_gi + 1] * _dy6 + global.__osn_gradients4d[_gi + 2] * _dz6 + global.__osn_gradients4d[_gi + 3] * _dw6);
            }
            
            // Contribution (1,0,0,1)
            var _dx7 = _dx0 - 1 - 2 * OSN_SQUISH_4D;
            var _dy7 = _dy0 - 0 - 2 * OSN_SQUISH_4D;
            var _dz7 = _dz0 - 0 - 2 * OSN_SQUISH_4D;
            var _dw7 = _dw0 - 1 - 2 * OSN_SQUISH_4D;
            var _attn7 = 2 - _dx7 * _dx7 - _dy7 * _dy7 - _dz7 * _dz7 - _dw7 * _dw7;
            if (_attn7 > 0) {
                _attn7 *= _attn7;
                _gi = global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(_xsb + 1) & 0xFF] + (_ysb + 0)) & 0xFF] + (_zsb + 0)) & 0xFF] + (_wsb + 1)) & 0xFF] & 0xFC;
            _value += _attn7 * _attn7 * (global.__osn_gradients4d[_gi] * _dx7 + global.__osn_gradients4d[_gi + 1] * _dy7 + global.__osn_gradients4d[_gi + 2] * _dz7 + global.__osn_gradients4d[_gi + 3] * _dw7);
            }
            
            // Contribution (0,1,1,0)
            var _dx8 = _dx0 - 0 - 2 * OSN_SQUISH_4D;
            var _dy8 = _dy0 - 1 - 2 * OSN_SQUISH_4D;
            var _dz8 = _dz0 - 1 - 2 * OSN_SQUISH_4D;
            var _dw8 = _dw0 - 0 - 2 * OSN_SQUISH_4D;
            var _attn8 = 2 - _dx8 * _dx8 - _dy8 * _dy8 - _dz8 * _dz8 - _dw8 * _dw8;
            if (_attn8 > 0) {
                _attn8 *= _attn8;
                _gi = global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(_xsb + 0) & 0xFF] + (_ysb + 1)) & 0xFF] + (_zsb + 1)) & 0xFF] + (_wsb + 0)) & 0xFF] & 0xFC;
            _value += _attn8 * _attn8 * (global.__osn_gradients4d[_gi] * _dx8 + global.__osn_gradients4d[_gi + 1] * _dy8 + global.__osn_gradients4d[_gi + 2] * _dz8 + global.__osn_gradients4d[_gi + 3] * _dw8);
            }
            
            // Contribution (0,1,0,1)
            var _dx9 = _dx0 - 0 - 2 * OSN_SQUISH_4D;
            var _dy9 = _dy0 - 1 - 2 * OSN_SQUISH_4D;
            var _dz9 = _dz0 - 0 - 2 * OSN_SQUISH_4D;
            var _dw9 = _dw0 - 1 - 2 * OSN_SQUISH_4D;
            var _attn9 = 2 - _dx9 * _dx9 - _dy9 * _dy9 - _dz9 * _dz9 - _dw9 * _dw9;
            if (_attn9 > 0) {
                _attn9 *= _attn9;
                _gi = global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(_xsb + 0) & 0xFF] + (_ysb + 1)) & 0xFF] + (_zsb + 0)) & 0xFF] + (_wsb + 1)) & 0xFF] & 0xFC;
            _value += _attn9 * _attn9 * (global.__osn_gradients4d[_gi] * _dx9 + global.__osn_gradients4d[_gi + 1] * _dy9 + global.__osn_gradients4d[_gi + 2] * _dz9 + global.__osn_gradients4d[_gi + 3] * _dw9);
            }
            
            // Contribution (0,0,1,1)
            var _dx10 = _dx0 - 0 - 2 * OSN_SQUISH_4D;
            var _dy10 = _dy0 - 0 - 2 * OSN_SQUISH_4D;
            var _dz10 = _dz0 - 1 - 2 * OSN_SQUISH_4D;
            var _dw10 = _dw0 - 1 - 2 * OSN_SQUISH_4D;
            var _attn10 = 2 - _dx10 * _dx10 - _dy10 * _dy10 - _dz10 * _dz10 - _dw10 * _dw10;
            if (_attn10 > 0) {
                _attn10 *= _attn10;
                _gi = global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(global.__osn_perm[(_xsb + 0) & 0xFF] + (_ysb + 0)) & 0xFF] + (_zsb + 1)) & 0xFF] + (_wsb + 1)) & 0xFF] & 0xFC;
            _value += _attn10 * _attn10 * (global.__osn_gradients4d[_gi] * _dx10 + global.__osn_gradients4d[_gi + 1] * _dy10 + global.__osn_gradients4d[_gi + 2] * _dz10 + global.__osn_gradients4d[_gi + 3] * _dw10);
            }
        }
    }
    
    return _value / OSN_NORM_4D;
}

// ============================================================================
// PUBLIC WRAPPERS (Fractal / Octave Blending)
// ============================================================================

/// @desc Generates 2D OpenSimplex noise with octave blending
/// @param {real} x X coordinate
/// @param {real} y Y coordinate
/// @param {real} amplitude Maximum amplitude of the noise (exclusive)
/// @param {real} octaves Number of octaves to blend (1+)
/// @return {real} Noise value in range [0, amplitude)
function open_simplex_noise(_x, _y, _amplitude = 1.0, _octaves = 1)
{
    var _total = 0;
    var _amp = 1.0;
    var _max_value = 0;
    
    for (var i = 0; i < _octaves; ++i)
    {
        var _frequency = 1 << i;
        
        _total += __osn_eval2d(_x * _frequency, _y * _frequency) * _amp;
        _max_value += _amp;
        
        _amp *= 0.5;      // Persistence
    }
    
    var _normalized = _total / _max_value;
    return (_normalized + 1.0) * 0.5 * _amplitude;
}

/// @desc Generates 3D OpenSimplex noise with octave blending
/// @param {real} x X coordinate
/// @param {real} y Y coordinate
/// @param {real} z Z coordinate
/// @param {real} amplitude Maximum amplitude of the noise (exclusive)
/// @param {real} octaves Number of octaves to blend (1+)
/// @return {real} Noise value in range [0, amplitude)
function open_simplex_noise_3d(_x, _y, _z, _amplitude = 1.0, _octaves = 1)
{
    var _total = 0;
    var _amp = 1.0;
    var _max_value = 0;
    
    for (var i = 0; i < _octaves; ++i)
    {
        var _frequency = 1 << i;
        
        _total += __osn_eval3d(_x * _frequency, _y * _frequency, _z * _frequency) * _amp;
        _max_value += _amp;
        
        _amp *= 0.5;      // Persistence
    }
    
    var _normalized = _total / _max_value;
    return (_normalized + 1.0) * 0.5 * _amplitude;
}

/// @desc Generates 4D OpenSimplex noise with octave blending
/// @param {real} x X coordinate
/// @param {real} y Y coordinate
/// @param {real} z Z coordinate
/// @param {real} w W coordinate
/// @param {real} amplitude Maximum amplitude of the noise (exclusive)
/// @param {real} octaves Number of octaves to blend (1+)
/// @return {real} Noise value in range [0, amplitude)
function open_simplex_noise_4d(_x, _y, _z, _w, _amplitude = 1.0, _octaves = 1)
{
    var _total = 0;
    var _amp = 1.0;
    var _max_value = 0;
    
    for (var i = 0; i < _octaves; ++i)
    {
        var _frequency = 1 << i;
        
        _total += __osn_eval4d(_x * _frequency, _y * _frequency, _z * _frequency, _w * _frequency) * _amp;
        _max_value += _amp;
        
        _amp *= 0.5;      // Persistence
    }
    
    var _normalized = _total / _max_value;
    return (_normalized + 1.0) * 0.5 * _amplitude;
}
