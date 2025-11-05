function shear_animation(beam, showDivs, exportGif)
    addpath(fullfile(pwd, 'lib', 'core', 'models'));


    if nargin < 2
        showDivs = false;
    end
    if nargin < 3
        exportGif = false;
    end

    x = linspace(0, beam.total_length, 500);
    f_dead = beam.shear_deathLoad();
    V_dead = f_dead(x);
    f_live_total = beam.shear_loadBetween(beam.load.live, 0, beam.total_length);
    V_live_total = f_live_total(x);
    V_total = V_dead + V_live_total;

    figure;
    set(gcf, 'Position', [100, 100, 900, 500]);

    n_values = [1, 2, 3, 4, 5, 6, 7, 8, 16, 32, 64, 128];

    currentFolder = fileparts(mfilename('fullpath'));
    resultsFolder = fullfile(currentFolder, '..', '..', 'results');
    if ~exist(resultsFolder, 'dir')
        mkdir(resultsFolder);
    end
    gifFile = fullfile(resultsFolder, 'shear_animation.gif');

    for i = 1:length(n_values)
        n = n_values(i);
        [~, envelope] = shear_envelope(beam, n);

        clf;
        hold on;
        plot(x, V_dead, '--', 'LineWidth', 2, 'Color', [0 0 0]);
        plot(x, envelope, '-', 'LineWidth', 2, 'Color', [1 0 0]);
        plot(x, V_total, ':', 'LineWidth', 2, 'Color', [0 0.7 0]);

        if showDivs
            divs = linspace(0, beam.total_length, n+1);
            for d = divs
                line([d d], ylim, 'Color', [0.5 0.5 0.5 0.3], 'LineWidth', 1);
            end
            ax = gca;
            ax.XGrid = 'off';
            ax.YGrid = 'on';
        else
            grid on;
        end

        xlabel('Longitud (m)');
        ylabel('Cortante (kN)');
        title(sprintf('Envolvente de Cortante (n = %d)', n));
        legend({'Carga Muerta', 'Envolvente', 'Muerta + Viva Total'}, 'Location', 'best');
        ylim([min([V_dead V_total envelope]) * 1.2, max([V_dead V_total envelope]) * 1.2]);
        hold off;

        drawnow;

        if exportGif
            frame = getframe(gcf);
            im = frame2im(frame);
            [A, map] = rgb2ind(im, 256);
            if i == 1
                imwrite(A, map, gifFile, "gif", "LoopCount", inf, "DelayTime", 0.8);
            else
                imwrite(A, map, gifFile, "gif", "WriteMode", "append", "DelayTime", 0.8);
            end
        else
            pause(0.8);
        end
    end

    if exportGif
        fprintf('✅ GIF exportado como "%s"\n', gifFile);
    end
end
