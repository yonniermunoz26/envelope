classdef DoubleOverhangingBeam
    properties
        left_length
        right_length
        center_length
        load (1,1) Load
    end

    methods
        function obj = DoubleOverhangingBeam(left_length, right_length, center_length, load)
            % Constructor
            obj.center_length = center_length;
            obj.left_length = left_length;
            obj.right_length = right_length;
            obj.load = load;
        end

        function f = shear_loadBetween(obj, load, startPos, endPos)
            f = obj.mix_function_handler(load, startPos, endPos, ...
                @(l,D,x)obj.shear_leftSideLoad(l,D,x), ...
                @(l,D,x)obj.shear_centerSideLoad(l,D,x), ...
                @(l,D,x)obj.shear_rightSideLoad(l,D,x));
        end

        function f = moment_loadBetween(obj, load, startPos, endPos)
            f = obj.mix_function_handler(load, startPos, endPos, ...
                @(l,D,x)obj.moment_leftSideLoad(l,D,x), ...
                @(l,D,x)obj.moment_centerSideLoad(l,D,x), ...
                @(l,D,x)obj.moment_rightSideLoad(l,D,x));
        end

        function f = shear_deathLoad(obj)
            f = obj.shear_loadBetween(obj.load.death, 0, obj.total_length);
        end

        function f = moment_deathLoad(obj)
            f = obj.moment_loadBetween(obj.load.death, 0, obj.total_length);
        end
    end

    methods (Access = private)
        function f = shear_leftSideLoad(obj, load, D, x)
            f = @(y) (y < D).*0 + ...
                     (y >= D & y < D + x).*(-load .* (y - D)) + ...
                     (y >= D + x & y < obj.left_length).*(-load .* x) + ...
                     (y >= obj.left_length & y < obj.left_length + obj.center_length).*(load .* x .* (obj.left_length - D - x/2) ./ obj.center_length) + ...
                     (y >= obj.left_length + obj.center_length & y < obj.total_length).*0;
        end

        function f = moment_leftSideLoad(obj, load, D, x)
            a = obj.left_length;
            b = obj.center_length;
            f = @(y) ...
                (y < D).*0 + ...
                (y >= D & y < D + x).*(- 0.5 .* load .* (y - D).^2) + ...
                (y >= D + x & y < a).*(- load .* x .* (y - D - x/2)) + ...
                (y >= a & y < a + b).*(- load .* x .* (a - D - x/2) .* (a + b - y) ./ b) + ...
                (y >= a + b & y < obj.total_length).*0;
        end

        function f = shear_centerSideLoad(obj, load, D, x)
            f = @(y) (y < obj.left_length).*0 + ...
                     (y >= obj.left_length & y < obj.left_length + D).*(load .* x .* (obj.center_length - D - x/2) ./ obj.center_length) + ...
                     (y >= obj.left_length + D & y < obj.left_length + D + x).*(load .* x .* (obj.center_length - D - x/2) ./ obj.center_length - load .* (y - obj.left_length - D)) + ...
                     (y >= obj.left_length + D + x & y < obj.left_length + obj.center_length).*(load .* x .* (obj.center_length - D - x/2) ./ obj.center_length - load .* x) + ...
                     (y >= obj.left_length + obj.center_length & y < obj.total_length).*0;
        end
    
        function f = moment_centerSideLoad(obj, load, D, x)
            a = obj.left_length;
            b = obj.center_length;
            f = @(y) ...
                (y < a).*0 + ...
                (y >= a & y < a + D).*(load .* x .* (b - D - x/2) .* (y - a) ./ b) + ...
                (y >= a + D & y < a + D + x).*(load .* x .* (b - D - x/2) .* (y - a) ./ b - 0.5 .* load .* (y - a - D).^2) + ...
                (y >= a + D + x & y < a + b).*(load .* x .* (D + x/2) .* (a + b - y) ./ b) + ...
                (y >= a + b & y < obj.total_length).*0;
        end

        function f = shear_rightSideLoad(obj, load, D, x)
            a = obj.left_length;
            b = obj.center_length;
        
            f = @(y) ...
                (y < a) .* 0 + ...
                (y >= a & y < a + b) .* (-load * x * (D + x/2) / b) + ...
                (y >= a + b & y < a + b + D) .* (-load * x * (D + x/2) / b + ...
                                                  load * x * (b + D + x/2) / b) + ...
                (y >= a + b + D & y < a + b + D + x) .* (load * (a + b + D + x - y)) + ...
                (y >= a + b + D + x & y <= obj.total_length) .* 0;
        end

        function f = moment_rightSideLoad(obj, load, D, x)
            a = obj.left_length;
            b = obj.center_length;
        
            f = @(y) ...
                (y < a) .* 0 + ...
                (y >= a & y < a + b) .* (-load * x * (D + x/2) * (y - a) / b) + ...
                (y >= a + b & y < a + b + D) .* (-load * x * (D + x/2) * (y - a) / b + ...
                                                  load * x * (b + D + x/2) * (y - a - b) / b) + ...
                (y >= a + b + D & y < a + b + D + x) .* (-0.5 *load * (a + b + D + x - y) .^2) + ...
                (y >= a + b + D + x & y <= obj.total_length) .* 0;
        end

        function f = mix_function_handler(obj, load, startPos, endPos, fn_left, fn_center, fn_right)
            startPos = max(0, startPos);
            endPos = min(obj.total_length, endPos);
            f_total = @(y) 0;

            if startPos < obj.left_length
                D = max(0, startPos);
                x = min(endPos, obj.left_length) - D;
                if x > 0
                    f_left = fn_left(load, D, x);
                    f_total = @(y) f_total(y) + f_left(y);
                end
            end

            if endPos > obj.left_length && startPos < (obj.left_length + obj.center_length)
                D = max(0, startPos - obj.left_length);
                x = min(endPos, obj.left_length + obj.center_length) - (obj.left_length + D);
                if x > 0
                    f_center = fn_center(load, D, x);
                    f_total = @(y) f_total(y) + f_center(y);
                end
            end

            if endPos > (obj.left_length + obj.center_length)
                D = max(0, startPos - (obj.left_length + obj.center_length));
                x = min(endPos, obj.total_length) - (obj.left_length + obj.center_length + D);
                if x > 0
                    f_right = fn_right(load, D, x);
                    f_total = @(y) f_total(y) + f_right(y);
                end
            end

            f = f_total;
        end
    end

    methods
        % Getters
        function L = total_length(obj)
            L = obj.left_length + obj.center_length + obj.right_length;
        end
    end
end
