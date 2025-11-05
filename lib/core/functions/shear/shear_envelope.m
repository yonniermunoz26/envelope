function [x, envelope] = shear_envelope(beam, n, showPlot, targetAxes)
    addpath(fullfile(pwd, 'lib', 'core', 'models'));
    if nargin < 3
        showPlot = false;
    end

    x = linspace(0, beam.total_length, 500);
    f_dead = beam.shear_deathLoad();
    V_dead = f_dead(x);
    envelope = V_dead;

    L = beam.total_length;

    if n >= 3
        totalParts = beam.left_length + beam.center_length + beam.right_length;

        n_left   = round(n * beam.left_length   / totalParts);
        n_right  = round(n * beam.right_length  / totalParts);

        if beam.left_length > 0 && n_left < 1
            n_left = 1;
        end
        if beam.right_length > 0 && n_right < 1
            n_right = 1;
        end

        n_center = max(n - n_left - n_right, 1);
        totalSegments = n_left + n_center + n_right;

        startPositions = zeros(1, totalSegments);
        endPositions   = zeros(1, totalSegments);

        idx = 1;

        if n_left > 0
            subLeft = beam.left_length / n_left;
            for i = 1:n_left
                startPositions(idx) = (i - 1) * subLeft;
                endPositions(idx)   = i * subLeft;
                idx = idx + 1;
            end
        end

        if n_center > 0
            subCenter = beam.center_length / n_center;
            offset = beam.left_length;
            for i = 1:n_center
                startPositions(idx) = offset + (i - 1) * subCenter;
                endPositions(idx)   = offset + i * subCenter;
                idx = idx + 1;
            end
        end

        if n_right > 0
            subRight = beam.right_length / n_right;
            offset = beam.left_length + beam.center_length;
            for i = 1:n_right
                startPositions(idx) = offset + (i - 1) * subRight;
                endPositions(idx)   = offset + i * subRight;
                idx = idx + 1;
            end
        end

        startPositions = startPositions(1:idx-1);
        endPositions   = endPositions(1:idx-1);

    else
        subLength = L / n;
        startPositions = (0:(n-1)) * subLength;
        endPositions   = (1:n) * subLength;
    end

    if showPlot
        if nargin == 4 && isvalid(targetAxes)
            ax = targetAxes;
            cla(ax);
            axes(ax);
        else
            figure;
            ax = gca;
        end

        hold(ax, 'on');
        grid(ax, 'on');
        plot(ax, x, V_dead, '--k', 'LineWidth', 1.5, 'DisplayName', 'Carga Muerta');
    end

    for i = 1:numel(startPositions)
        startPos = startPositions(i);
        endPos = endPositions(i);

        f_live = beam.shear_loadBetween(beam.load.live, startPos, endPos);
        V_live = f_live(x);

        sameSign = sign(V_dead) == sign(V_live);
        envelope = envelope + sameSign .* V_live;

        if showPlot
            color = rand(1, 3);
            plot(ax, x, V_live, 'Color', [color 0.6], 'LineWidth', 1.2, ...
                'DisplayName', sprintf('Tramo %d', i));
        end
    end

    if showPlot
        plot(ax, x, envelope, '-r', 'LineWidth', 2, 'DisplayName', 'Envolvente');
        xlabel(ax, 'Longitud (m)');
        ylabel(ax, 'Cortante (kN)');
        title(ax, sprintf('Envolvente de Cortante con %d Tramos', n));
        legend(ax, 'Location', 'bestoutside');
        set(ax, 'YDir', 'normal');
        hold(ax, 'off');
    end
end
