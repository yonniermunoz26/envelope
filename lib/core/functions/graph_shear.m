addpath(fullfile(pwd, '..', 'models'));

% Crear la viga con una carga de prueba
beam = DoubleOverhangingBeam(1, 0, 4, Load(3, 2));

% Parámetros de carga aplicada
l = 3;          % magnitud de carga (kN/m)
startPos = 0;   % inicio del tramo cargado (m)
endPos = 5;     % fin del tramo cargado (m)

% Obtener funciones de momento y cortante
f_v = beam.shear_loadBetween(l, startPos, endPos);

% Evaluar en una malla de puntos
x = linspace(0, beam.total_length, 500);
V = f_v(x);

% Graficar
figure;
plot(x, V, 'LineWidth', 2, 'Color', [1 0 0]);  % rojo punteado

xlabel('Longitud (m)');
ylabel('Cortante (kN)');
title(sprintf('Diagrama de Cortante (carga entre %.2f m y %.2f m)', startPos, endPos));
legend('Cortante', 'Location', 'best');
grid on;
