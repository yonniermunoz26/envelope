classdef Load
    properties
        live
        death
    end
    methods
        function obj = Load(live, death)
            if nargin > 0
                obj.live = live;
                obj.death = death;
            else
                obj.live = 0;
                obj.death = 0;
            end
        end
    end
end