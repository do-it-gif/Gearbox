% 4:1 HELICAL PLANETARY GEARBOX - DESIGN CALCULATION
% Ring fixed (housing), sun = input, carrier = output. Printed, greased.
% Units: mm, N, N*mm, MPa, rpm. Angles in degrees unless noted.
clear; clc;

% 0. INPUTS
Zs = 18;  Zp = 18;  Zr = 54;  N = 3;     % teeth, no. of planets
mn = 1.5;  an = 20;  beta = 20;  F = 15; % normal module, normal PA, helix, face width
D_out = 100;                             % housing OD
T_in  = 500;     % input torque [N*mm]
n_s   = 300;     % input speed [rpm]
K_g   = 1.2;     % planet load-share factor 
K_v   = 1.1;     % dynamic factor 
Y     = 0.33;    % Lewis form factor at Zv ~ 21.7
s_all = 15;      % allowable bending stress, printed PLA/PETG [MPa] (ASSUMED 10-20)
eta0  = 0.90;    % basic mesh efficiency sun-planet x planet-ring
C_b = 1720; C0_b = 680;   % 625 bearing C / C0 [N]
s_b = 5;         % centre spacing of the 2 stacked planet bearings [mm]

% 1. KINEMATICS
% i = 1 + Zr/Zs ; coaxial Zp = (Zr-Zs)/2 ; assembly (Zs+Zr)/N intege
i      = 1 + Zr/Zs;
coax   = (Zr - Zs)/2;
assy   = (Zs + Zr)/N;
n_c    = n_s/i;
n_prel = -(Zs/Zp)*(n_s - n_c);           % planet vs carrier (bearing speed)
f_mesh = Zs*(n_s - n_c)/60;
fprintf('--- 1. Kinematics ---\n i = %.3f | Zp coaxial = %g | (Zs+Zr)/N = %.2f (must be integer)\n', i, coax, assy);
fprintf(' n_carrier = %.1f rpm | planet bearing = %.1f rpm | mesh freq = %.1f Hz\n', n_c, n_prel, f_mesh);

% 2. GEOMETRY
% mt = mn/cos(b) ; at = atan(tan(an)/cos(b)) ; d = mt Z ; db = d cos(at)
% external: da = d + 2mn, df = d - 2.5mn | internal ring: da = d - 2mn, df = d + 2.5mn
mt  = mn/cosd(beta);
at  = atand(tand(an)/cosd(beta));
ds  = mt*Zs;  dp = mt*Zp;  dr = mt*Zr;
dbs = ds*cosd(at);  dbp = dp*cosd(at);  dbr = dr*cosd(at);
das = ds + 2*mn;  dap = dp + 2*mn;  dar = dr - 2*mn;
dfs = ds - 2.5*mn;                 dfr = dr + 2.5*mn;
a   = (ds + dp)/2;
wall = (D_out - dfr)/2;
Zv   = Zs/cosd(beta)^3;
gap  = 2*a*sind(180/N) - dap;      % planet tip-to-tip clearance
fprintf('--- 2. Geometry ---\n mt = %.4f | at = %.3f deg | Zv = %.1f (>17 no undercut)\n', mt, at, Zv);
fprintf(' sun/planet d = %.3f, db = %.3f, da = %.3f, df = %.3f\n', ds, dbs, das, dfs);
fprintf(' ring d = %.3f, db = %.3f, da(inner) = %.3f, df = %.3f\n', dr, dbr, dar, dfr);
fprintf(' centre dist a = %.3f | carrier PCD = %.3f | ring wall = %.2f | planet gap = %.1f\n', a, 2*a, wall, gap);

% 3. HELIX TWIST
% twist = 360 F tan(b)/(pi d)
twS = 360*F*tand(beta)/(pi*ds);
twR = 360*F*tand(beta)/(pi*dr);
fprintf('--- 3. Twist over F ---\n sun/planet = %.2f deg | ring = %.2f deg\n', twS, twR);

% 4. CONTACT RATIOS
% pb = pi mt cos(at)
% ext: ea = (sqrt(ra1^2-rb1^2) + sqrt(ra2^2-rb2^2) - a sin(at))/pb
% int: ea = (sqrt(rap^2-rbp^2) - sqrt(rar^2-rbr^2) + a sin(at))/pb
% overlap: eb = F sin(b)/(pi mn)
pb  = pi*mt*cosd(at);
Lsp = sqrt((das/2)^2-(dbs/2)^2) + sqrt((dap/2)^2-(dbp/2)^2) - a*sind(at);
Lpr = sqrt((dap/2)^2-(dbp/2)^2) - sqrt((dar/2)^2-(dbr/2)^2) + a*sind(at);
ea_sp = Lsp/pb;  ea_pr = Lpr/pb;
eb    = F*sind(beta)/(pi*mn);
fprintf('--- 4. Contact ratio ---\n sun-planet ea = %.2f | planet-ring ea = %.2f | eb = %.2f\n', ea_sp, ea_pr, eb);
fprintf(' total: sun-planet = %.2f | planet-ring = %.2f\n', ea_sp+eb, ea_pr+eb);

% 5. FORCES (per planet mesh)
% Ft = 2T/(N ds) ; Fr = Ft tan(at) ; Fa = Ft tan(b) ; Fn = Ft/(cos(an) cos(b))
% pin load = 2Ft ; planet tilt couple M = Fa dp ; sun thrust = N Fa
Ft = 2*T_in/(N*ds);
Fr = Ft*tand(at);  Fa = Ft*tand(beta);  Fn = Ft/(cosd(an)*cosd(beta));
F_pin  = 2*Ft*K_g;
M_tilt = Fa*K_g*dp;
F_sun  = N*Fa;
fprintf('--- 5. Forces (T_in = %.0f Nmm) ---\n Ft = %.1f N (x Kg = %.1f) | Fr = %.2f | Fa = %.2f | Fn = %.1f N\n', ...
        T_in, Ft, Ft*K_g, Fr, Fa, Fn);
fprintf(' pin load = %.1f N | planet tilt = %.0f Nmm | sun axial thrust = %.1f N\n', F_pin, M_tilt, F_sun);

% 6. OUTPUT TORQUE + EFFICIENCY
% eta = 1 - (1-eta0) Zr/(Zr+Zs) ; T_out = T_in i eta
eta   = 1 - (1-eta0)*Zr/(Zr+Zs);
T_out = T_in*i*eta;
fprintf('--- 6. Output ---\n eta = %.3f | T_out = %.2f Nm\n', eta, T_out/1e3);

% 7. TOOTH BENDING (Lewis, helical)
% sigma = Ft Kg Kv/(F mn Y) ; T_in,max from sigma = s_all
sig    = Ft*K_g*K_v/(F*mn*Y);
SF_b   = s_all/sig;
Ft_max = s_all*F*mn*Y/(K_g*K_v);
T_inmax = Ft_max*N*ds/2;
fprintf('--- 7. Bending ---\n sigma = %.2f MPa | SF = %.1f (vs %g MPa)\n', sig, SF_b, s_all);
fprintf(' bending-limited: T_in = %.2f Nm -> T_out = %.1f Nm (wear/creep limit lower)\n', T_inmax/1e3, T_inmax*i*eta/1e3);

% 8. PLANET BEARINGS (2 per planet)
% worst bearing: P = F_pin/2 + M_tilt/s_b ; L10 = (C/P)^3 [1e6 rev] ; s0 = C0/P
P     = F_pin/2 + M_tilt/s_b;
L10   = (C_b/P)^3;                       % million rev
L10h  = L10*1e6/(60*abs(n_prel));
s0    = C0_b/P;
fprintf('--- 8. Planet bearing ---\n P = %.1f N | L10 = %.3g Mrev = %.3g h | s0 = %.1f\n', P, L10, L10h, s0);

% SUMMARY
chk = {'Assembly (Zs+Zr)/N integer', abs(assy-round(assy)) < 1e-9;
       'No undercut Zv > 17',         Zv > 17;
       'Ring wall >= 4 mm',           wall >= 4;
       'Total contact ratio > 2',     min(ea_sp,ea_pr)+eb > 2;
       'Overlap ratio eb >= 1',       eb >= 1;
       'Bending SF > 2',              SF_b > 2;
       'Bearing s0 > 2',              s0 > 2};
fprintf('\n===== SUMMARY =====\n');
for k = 1:size(chk,1)
    s = 'FAIL'; if chk{k,2}, s = 'ok'; end
    fprintf(' %-28s %s\n', chk{k,1}, s);
end