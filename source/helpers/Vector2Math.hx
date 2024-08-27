package helpers;

import echo.math.Vector2;


class Vector2Math {
    public static function distanceTo(a:Vector2, b:Vector2):Float {
        return Math.sqrt(Math.pow(a.x - b.x, 2) + Math.pow(a.y - b.y, 2));
    }
}