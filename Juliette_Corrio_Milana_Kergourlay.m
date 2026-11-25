close all; 
clear; 
clc; 

g = 9.81; % m/s^2

Ti = 0; % temps initial et final
Tf = 100;
dt = 0.001;

T_ = (Ti : dt : Tf)'; %vecteur temps
Nbs = length(T_);
ui = 50 / 3.6; %vitesse lineaire du vehicule au centre de gravite en m/s
u_ = ui * ones(Nbs, 1); 

Parametre = parametre("Peugeot");

id = Parametre.id; % Rapport de demultiplication direction
%on met consant pour l'instant mais a changer dans le future
angle_volant_deg = 70; % angle volant en deg
beta_deg = angle_volant_deg /id ; %angle de braquage en deg
betai = beta_deg * pi / 180; %angle de braquage en rad
beta_ = betai * ones(Nbs, 1);

mu = mu_sol("Beton sec");

%cas lineaire avec saturation
[delta_, deltaf_, deltar_, dtheta_, X_, Y_, ay_, Fyr_] = dynamique(u_, beta_, 1, 0, 0, mu, Parametre);
% 0 = lineaire
% 1 = lineaire avec saturation
[dtheta1_, X1_, Y1_, ay1_ ] = cinematique(u_,beta_, Parametre);

%def ecart en pourcent vitesse de lacet cinematique et dynamique
e_ = zeros(1, Nbs);
for i = 1:Nbs 
    dtheta1_0 = dtheta1_(i);
    dtheta_0 = dtheta_(i);
    e_0 = abs((1- dtheta_0 / dtheta1_0)) *100;
    e_(i) = e_0;
end


%affichage des resultats 
figure('Name', 'Résultats de la Simulation');

subplot(2,3,1);

yyaxis left
plot(T_, u_ * 3.6, 'b', 'LineWidth', 1.5);
ylabel('Vitesse linéaire du véhicule au CdG, u (km/h)');
ylim([0 max(u_)*1.2*3.6]);
ax = gca;
ax.YColor = 'b';

yyaxis right
plot(T_, beta_*id*180/pi, 'r', 'LineWidth', 1.5);
ylabel('Angle du volant (deg)');
ax.YColor = 'r';

xlabel('Temps (s)');
title('Consignes de vitesse et de braquage');
legend('Vitesse u', 'Angle du volant', 'Location', 'best');
grid on;


subplot(2,3,2);
plot(T_, delta_*180/pi, 'b');
xlabel('Temps (s)'); ylabel('\delta (deg)');
title('Angle de dérive global'); grid on;

subplot(2,3,3);
plot(T_, deltaf_*180/pi, 'Color', '#9400D3', 'LineWidth', 1.5);
hold on;
plot(T_, deltar_*180/pi, 'Color', '#228B22', 'LineWidth', 1.5);
hold off;
xlabel('Temps (s)'); ylabel('Angle (deg)');
legend('\delta_f (avant)', '\delta_r (arrière)');
title('Angles de dérives'); grid on;

subplot(2,3,4);
yyaxis left
plot(T_, dtheta_*180/pi,'b-', T_, dtheta1_*180/pi,'r-');
ylabel('$\dot{\theta}$ (deg/s)', 'Interpreter', 'latex');
ax = gca;
ax.YColor = 'b';

yyaxis right
plot(T_, e_, 'k--');
ylabel('Ecart en \%', 'Interpreter', 'latex', 'Color', 'k');
ax.YColor = 'k';

legend({'$\dot{\theta}$ (dynamique)','$\dot{\theta}$ (cinematique)', 'Ecart en \%'},'Interpreter', 'latex');
xlabel('Temps (s)');
title('Vitesse de lacet'); grid on;

subplot(2,3,5);
plot(X_, Y_,'b', X1_, Y1_,'r');
xlabel('X (m)'); ylabel('Y (m)');
legend('Dynamique', 'Cinématique');
title('Trajectoire du CdG'); grid on; axis equal;

subplot(2,3,6);
plot(T_, ay_/9.81, 'b', T_, ay1_/9.81,'r');
legend('Dynamique', 'Cinématique');
xlabel('Temps (s)'); ylabel('a_y (g)');
title('Accélération latérale du CdG'); grid on;




