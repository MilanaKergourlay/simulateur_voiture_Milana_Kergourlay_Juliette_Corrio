function interface_simulation2
    % Donnees de la simulation 
    Ti = 0; Tf = 100; dt = 0.001;
    T_  = (Ti:dt:Tf)';
    Nbs = length(T_);

    tl = []; % tiledlayout 

    % Fenetre principale
    fig = uifigure('Name', 'Simulation véhicule, cinématique et dynamique', 'Position', [60 40 1350 780]);
    gMain = uigridlayout(fig, [1 2]);
    gMain.ColumnWidth = {300, '1x'};
    gMain.Padding = [5 5 5 5];

    % Commande
    gC = uigridlayout(gMain, [13 1]);
    gC.RowHeight = {22, 28, 22, 28, 22, 28, 22, 50, 22, 160, 28, 40, 22};
    gC.Scrollable = 'on';
    gC.RowSpacing = 6;

    uilabel(gC, 'Text', 'Véhicule', 'FontWeight', 'bold');
    ddVeh = uidropdown(gC, 'Items', {'Peugeot', 'Ferrari'}, 'Value', 'Peugeot');

    uilabel(gC, 'Text', 'Type de sol', 'FontWeight', 'bold');
    ddSol = uidropdown(gC, ...
        'Items', {'Beton sec', 'Beton mouillé', 'Gravier', 'Boue'}, 'Value', 'Beton sec');

    uilabel(gC, 'Text', 'Contact pneumatique', 'FontWeight', 'bold');
    ddCont = uidropdown(gC, ...
        'Items', {'Linéaire', 'Linéaire avec saturation'}, 'ItemsData', [0 1], 'Value', 1);

    % Vitesse : curseur
    lblVit = uilabel(gC, 'Text', 'Vitesse : 50 km/h', 'FontWeight', 'bold');
    sldVit = uislider(gC, 'Limits', [5 130], 'Value', 50, ...
        'MajorTicks', [5 30 60 90 130], ...
        'ValueChangingFcn', @(~, e) set(lblVit, 'Text', sprintf('Vitesse : %.0f km/h', e.Value)), ...
        'ValueChangedFcn',  @(s, ~) set(lblVit, 'Text', sprintf('Vitesse : %.0f km/h', s.Value)));

    % Angle du volant : bouton rotatif + champ numérique synchronisés
    lblVol = uilabel(gC, 'Text', 'Angle du volant : 70 °', 'FontWeight', 'bold');
    knob = uiknob(gC, 'continuous', 'Limits', [-360 360], 'Value', 70, ...
        'MajorTicks', -360:90:360, ...
        'ValueChangingFcn', @(~, e) majVolant(e.Value), ...
        'ValueChangedFcn',  @(s, ~) majVolant(s.Value));
    edtVol = uieditfield(gC, 'numeric', 'Limits', [-360 360], 'Value', 70, ...
        'ValueDisplayFormat', '%.1f °', ...
        'ValueChangedFcn', @(s, ~) majVolant(s.Value));

    btn = uibutton(gC, 'Text', 'Lancer la simulation', 'FontWeight', 'bold', ...
                   'ButtonPushedFcn', @(~, ~) simuler());

    %  Zone des courbes 
    pPlot = uipanel(gMain, 'BorderType', 'none');

    simuler();   % premiere simulation avec les valeurs par defaut

    function majVolant(val)
        val = max(-360, min(360, val));
        knob.Value = val;
        edtVol.Value = val;
        lblVol.Text = sprintf('Angle du volant : %.1f °', val);
    end

    function simuler()
        btn.Enable = 'off';
        try
            % Lecture des choix de l'utilisateur
            Parametre = parametre(ddVeh.Value);
            mu   = mu_sol(ddSol.Value);
            type = ddCont.Value; % 0 = linéaire, 1 = avec saturation
            id   = Parametre.id;

            u_ = (sldVit.Value / 3.6) * ones(Nbs, 1);
            betai = (knob.Value / id) * pi / 180;
            beta_ = betai * ones(Nbs, 1);

            % Simulation 
            [delta_, deltaf_, deltar_, dtheta_, X_, Y_, ay_] = dynamique(u_, beta_, type, 0, 0, mu, Parametre);
            [dtheta1_, X1_, Y1_, ay1_] = cinematique(u_, beta_, Parametre);

            % Ecart en % entre vitesse de lacet cinematique et dynamique
            e_ = abs(1 - dtheta_ ./ dtheta1_) * 100;

            % Affichage des résultats 
            if ~isempty(tl) && isvalid(tl)
                delete(tl);
            end
            tl = tiledlayout(pPlot, 2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

            % Consignes de vitesse et d'angle volant
            ax = nexttile(tl, 1);
            yyaxis(ax, 'left');
            plot(ax, T_, u_ * 3.6, 'b', 'LineWidth', 1.5);
            ylabel(ax, 'Vitesse linéaire du véhicule au CdG, u (km/h)');
            ylim(ax, [0 max(u_)*1.2*3.6]);
            ax.YColor = 'b';

            yyaxis(ax, 'right');
            plot(ax, T_, beta_ * id * 180/pi, 'r', 'LineWidth', 1.5);
            ylabel(ax, 'Angle du volant (deg)');
            ax.YColor = 'r';

            xlabel(ax, 'Temps (s)');
            title(ax, 'Consignes de vitesse et de braquage');
            legend(ax, 'Vitesse u', 'Angle du volant', 'Location', 'best');
            grid(ax, 'on');

            % Angle de derive global
            ax = nexttile(tl, 2);
            plot(ax, T_, delta_*180/pi, 'b');
            xlabel(ax, 'Temps (s)'); 
            ylabel(ax, '\delta (deg)');
            title(ax, 'Angle de dérive global'); 
            grid(ax, 'on');

            % Angles de derive avant / arriere
            ax = nexttile(tl, 3);
            plot(ax, T_, deltaf_*180/pi, 'Color', '#9400D3', 'LineWidth', 1.5);
            hold(ax, 'on');
            plot(ax, T_, deltar_*180/pi, 'Color', '#228B22', 'LineWidth', 1.5);
            hold(ax, 'off');
            xlabel(ax, 'Temps (s)'); ylabel(ax, 'Angle (deg)');
            legend(ax, '\delta_f (avant)', '\delta_r (arrière)');
            title(ax, 'Angles de dérives'); 
            grid(ax, 'on');

            % Vitesse de lacet
            ax = nexttile(tl, 4);
            yyaxis(ax, 'left');
            plot(ax, T_, dtheta_*180/pi, 'b-', T_, dtheta1_*180/pi, 'r-');
            ylabel(ax, '$\dot{\theta}$ (deg/s)', 'Interpreter', 'latex');
            ax.YColor = 'b';
            yyaxis(ax, 'right');
            plot(ax, T_, e_, 'k--');
            ylabel(ax, 'Ecart en \%', 'Interpreter', 'latex', 'Color', 'k');
            ax.YColor = 'k';
            legend(ax, {'$\dot{\theta}$ (dynamique)', '$\dot{\theta}$ (cinematique)', 'Ecart en \%'}, 'Interpreter', 'latex');
            xlabel(ax, 'Temps (s)');
            title(ax, 'Vitesse de lacet'); 
            grid(ax, 'on');

            % trajectoire du CdG
            ax = nexttile(tl, 5);
            plot(ax, X_, Y_, 'b', X1_, Y1_, 'r');
            xlabel(ax, 'X (m)'); ylabel(ax, 'Y (m)');
            legend(ax, 'Dynamique', 'Cinématique');
            title(ax, 'Trajectoire du CdG'); 
            grid(ax, 'on'); 
            axis(ax, 'equal');

            % Acceleration laterale
            ax = nexttile(tl, 6);
            plot(ax, T_, ay_/9.81, 'b', T_, ay1_/9.81, 'r');
            legend(ax, 'Dynamique', 'Cinématique');
            xlabel(ax, 'Temps (s)'); ylabel(ax, 'a_y (g)');
            title(ax, 'Accélération latérale du CdG'); grid(ax, 'on');

        catch err
            lblEtat.Text = 'Erreur de simulation.';
            uialert(fig, err.message, 'Erreur');
        end
        btn.Enable = 'on';
    end
end