% XRAYREFLECTIVITY Calculate the x-ray thick mirror reflectivity; and
% (optional) Plot reflectivity  vs. energy, wavelength or angle of
% incidence.
%
% XRAYREFLECTIVITY(SYMBOL, DENSITY, ENERGYORWAVELENGTH, GRAZINGANGLE, POLARIZATION, FIGNUM, PLOTPARAMS)
%              SYMBOL: Chemical symbol of the molecule
%             DENSITY: Density in grams per cubic centimeter
%  ENERGYORWAVELENGTH: x-ray energy in eV or x-ray wavelength in Angstrom
%        GRAZINGANGLE: Angle of incidence relative to surface in degrees
%        POLARIZATION: x-ray polarization: 1=s and -1=p
%              FIGNUM: (optional) Figure number in which to plot the index of refraction
%          PLOTPARAMS: (optional) string defining the plot options (color, marker, line style, etc.)
%
% Reflectivity vs. energy (wavelength) is plotted if ENERGYORWAVELENGTH is
% a vector. Reflectivity vs. angle of incidence is plotted if
% INCIDENCEANGLE is a vector. If ENERGYORWAVELENGTH or INCIDENCEANGLE is a
% 2 element vector, the reflectivity is calculated for 501 points wihin the
% range specified by ENERGYORWAVELENGTH or INCIDENCEANGLE.
%
% Example 1 (x-ray index of refraction vs. energy):
%   XrayReflectivity('Si', 2.35, [1000 5000], 1, '-b')
%   XrayReflectivity('Au', 19.32, [1000 5000], 1, ':r')
%
% Exampe 2 (x-ray index of refraction vs. wavelength):
%   XrayIndexOfRefraction('InSb', 5.7, [0.2 2], 2)
%
% Last update: 02-03-2011, Maher Harb


function R = XrayReflectivity(Symbol, Density, EnergyOrWavelength, GrazingAngle, Polarization, FigNum, PlotParams)

GrazingAngle = GrazingAngle*pi/180; % convert to rad

if size(EnergyOrWavelength,2)>1
    EnergyOrWavelength = EnergyOrWavelength';
end

if size(EnergyOrWavelength,1)==2
    if EnergyOrWavelength(1)==EnergyOrWavelength(2)
        EnergyOrWavelength = EnergyOrWavelength(1);
    else
        EnergyOrWavelength = linspace(EnergyOrWavelength(1),EnergyOrWavelength(2), 501)';
    end
end

if EnergyOrWavelength(1)>1 % Energy
    Energy = EnergyOrWavelength;
    lambda = Energy2Wavelength(Energy);
else
    lambda = EnergyOrWavelength*1e-10; % m
end

if size(EnergyOrWavelength,1)>1
    GrazingAngle = GrazingAngle(1);
else
    if size(GrazingAngle,2)>1
        GrazingAngle = GrazingAngle';
    end
    if size(GrazingAngle,1)==2
        if GrazingAngle(1)==GrazingAngle(2)
            GrazingAngle = GrazingAngle(1);
        else
            GrazingAngle = linspace(GrazingAngle(1), GrazingAngle(2), 501)';
        end
    end
end

IndexOfRefraction = XrayIndexOfRefraction(Symbol, Density, EnergyOrWavelength);
sigma = IndexOfRefraction(:,1);
beta = IndexOfRefraction(:,2);
n = 1 - sigma -1i*beta;

if Polarization==1 % s
    r=(cos(pi/2-GrazingAngle)-sqrt(n.^2-sin(pi/2-GrazingAngle).^2))./(cos(pi/2-GrazingAngle)+sqrt(n.^2-sin(pi/2-GrazingAngle).^2));
else % p
    r=(-n.^2*cos(pi/2-GrazingAngle)+sqrt(n.^2-sin(pi/2-GrazingAngle).^2))./(n.^2*cos(pi/2-GrazingAngle)+sqrt(n.^2-sin(pi/2-GrazingAngle).^2));
end
R = abs(r).^2;

GrazingAngle = GrazingAngle*180/pi; % convert back to deg.

if nargin>5 % plot result
    
    if nargin>6
        PltClr = PlotParams;
    else
        PltClr = 'b';
    end
    
    figure(FigNum)
    
    [~, ~, ~, l_text] = legend;
    
    if size(EnergyOrWavelength,1)>1
        if EnergyOrWavelength(1)>1 % Energy
            plot(EnergyOrWavelength/1000, R, PltClr);
            xlabel('Energy (KeV)')
        else
            plot(EnergyOrWavelength, R, PltClr);
            xlabel(strcat(['Wavelength (', char(197), ')']))
        end
        legend(l_text, Symbol)
        title(strcat(['Grazing angle = ', num2str(GrazingAngle,'%4.2f'), ' deg']))
    else
        semilogy(GrazingAngle, R, PltClr);
        xlabel('Grazing angle (deg)')
        if EnergyOrWavelength(1)>1 % Energy
            title(strcat(['X-ray energy = ', num2str(round(EnergyOrWavelength/1000)), ' keV']))
        else
            title(strcat(['X-ray wavelength = ', num2str(EnergyOrWavelengt,'%4.2f'), ' ', char(197)]))
        end
        legend(l_text, Symbol)
    end
    ylabel('X-ray Reflectivity')
    hold on
end

end

