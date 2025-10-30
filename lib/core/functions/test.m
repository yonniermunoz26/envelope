addpath(fullfile(pwd, '..', 'models'));

% Crear la viga con una carga de prueba
beam = DoubleOverhangingBeam(1, 2, 3, Load(5, 2));

% Parámetros de carga aplicada
l = 2;          % magnitud de carga (kN/m)
startPos = 4.5;   % inicio del tramo cargado (m)
endPos = 5.5;     % fin del tramo cargado (m)

% Obtener funciones de momento y cortante
f_m = beam.moment_loadBetween(l, startPos, endPos);
f_v = beam.shear_loadBetween(l, startPos, endPos);

% Evaluar en una malla de puntos
x = linspace(0, beam.total_length, 500);
M = f_m(x);
V = f_v(x);

% Graficar
figure;
plot(x, M, 'LineWidth', 2, 'Color', [0 0.4 1]);  % azul
hold on;
plot(x, V, '--', 'LineWidth', 2, 'Color', [1 0 0]);  % rojo punteado
hold off;

xlabel('Longitud (m)');
ylabel('Momento (kN·m) / Cortante (kN)');
title('Diagramas de Momento y Cortante (carga entre 2 m y 3 m)');
legend('Momento', 'Cortante', 'Location', 'best');
grid on;
