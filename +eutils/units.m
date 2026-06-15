classdef units
%EUTILS.UNITS 工程单位换算
%
%   eutils.units.convert(100, 'mph', 'kmh')
%   eutils.units.convert(1, 'atm', 'Pa')
%   eutils.units.convert(72, 'fahrenheit', 'celsius')
%
%   支持的单位类别:
%     长度: m, cm, mm, km, in, ft, yd, mi, um, nm
%     质量: kg, g, mg, lb, oz, ton
%     时间: s, ms, min, h, day
%     温度: celsius, fahrenheit, kelvin
%     压力: Pa, kPa, MPa, bar, atm, psi, torr, mmHg
%     能量: J, kJ, cal, kcal, kWh, eV, BTU
%     功率: W, kW, MW, hp, BTU/h
%     力: N, kN, lbf, dyn, kgf
%     速度: ms, kmh, mph, knot, fps
%     面积: m2, cm2, mm2, ft2, in2, acre
%     体积: m3, L, mL, gal, ft3, in3
%     角度: deg, rad
%     频率: Hz, kHz, MHz, GHz, rpm
%
%   See also eutils.constants

    methods(Static)
        function result = convert(value, from, to)
        %CONVERT 单位换算
        %
        %   result = eutils.units.convert(100, 'mph', 'kmh')

            % 获取转换因子（相对于 SI 单位）
            from_factor = get_factor(from);
            to_factor = get_factor(to);

            % 检查单位类别
            from_cat = get_category(from);
            to_cat = get_category(to);

            if ~strcmp(from_cat, to_cat)
                error('eutils:units:categoryMismatch', ...
                    '不能在不同类别间换算: %s (%s) → %s (%s)', ...
                    from, from_cat, to, to_cat);
            end

            % 温度特殊处理
            if strcmp(from_cat, 'temperature')
                result = convert_temperature(value, from, to);
            else
                % 通用换算
                si_value = value * from_factor;
                result = si_value / to_factor;
            end

            fprintf('📐 单位换算:\n');
            fprintf('   %.6g %s = %.6g %s\n', value, from, result, to);
        end

        function list = list_units(category)
        %LIST_UNITS 列出支持的单位
        %
        %   eutils.units.list_units('pressure')

            if nargin < 1
                % 列出所有类别
                categories = {'length', 'mass', 'time', 'temperature', ...
                    'pressure', 'energy', 'power', 'force', 'velocity', ...
                    'area', 'volume', 'angle', 'frequency'};
                fprintf('📋 支持的单位类别:\n');
                for i = 1:numel(categories)
                    fprintf('   %s\n', categories{i});
                end
            else
                % 列出特定类别的单位
                units_map = get_units_map();
                if isfield(units_map, category)
                    fprintf('📋 %s 类别的单位:\n', category);
                    fields = fieldnames(units_map.(category));
                    for i = 1:numel(fields)
                        fprintf('   %s\n', fields{i});
                    end
                else
                    fprintf('未知类别: %s\n', category);
                end
            end
        end
    end
end

function factor = get_factor(unit)
    units_map = get_units_map();

    % 遍历所有类别
    categories = fieldnames(units_map);
    for i = 1:numel(categories)
        cat = units_map.(categories{i});
        if isfield(cat, unit)
            factor = cat.(unit);
            return;
        end
    end

    error('eutils:units:unknownUnit', '未知单位: %s', unit);
end

function cat = get_category(unit)
    units_map = get_units_map();

    categories = fieldnames(units_map);
    for i = 1:numel(categories)
        if isfield(units_map.(categories{i}), unit)
            cat = categories{i};
            return;
        end
    end

    error('eutils:units:unknownUnit', '未知单位: %s', unit);
end

function result = convert_temperature(value, from, to)
    % 先转为开尔文
    switch lower(from)
        case 'celsius'
            K = value + 273.15;
        case 'fahrenheit'
            K = (value - 32) * 5/9 + 273.15;
        case 'kelvin'
            K = value;
    end

    % 再从开尔文转为目标
    switch lower(to)
        case 'celsius'
            result = K - 273.15;
        case 'fahrenheit'
            result = (K - 273.15) * 9/5 + 32;
        case 'kelvin'
            result = K;
    end
end

function map = get_units_map()
    % 长度 (相对于米)
    map.length.m = 1;
    map.length.cm = 0.01;
    map.length.mm = 0.001;
    map.length.km = 1000;
    map.length.um = 1e-6;
    map.length.nm = 1e-9;
    map.length.in = 0.0254;
    map.length.ft = 0.3048;
    map.length.yd = 0.9144;
    map.length.mi = 1609.344;

    % 质量 (相对于千克)
    map.mass.kg = 1;
    map.mass.g = 0.001;
    map.mass.mg = 1e-6;
    map.mass.lb = 0.453592;
    map.mass.oz = 0.0283495;
    map.mass.ton = 1000;

    % 时间 (相对于秒)
    map.time.s = 1;
    map.time.ms = 0.001;
    map.time.min = 60;
    map.time.h = 3600;
    map.time.day = 86400;

    % 温度 (特殊处理)
    map.temperature.celsius = 1;
    map.temperature.fahrenheit = 1;
    map.temperature.kelvin = 1;

    % 压力 (相对于帕斯卡)
    map.pressure.Pa = 1;
    map.pressure.kPa = 1000;
    map.pressure.MPa = 1e6;
    map.pressure.bar = 1e5;
    map.pressure.atm = 101325;
    map.pressure.psi = 6894.76;
    map.pressure.torr = 133.322;
    map.pressure.mmHg = 133.322;

    % 能量 (相对于焦耳)
    map.energy.J = 1;
    map.energy.kJ = 1000;
    map.energy.cal = 4.184;
    map.energy.kcal = 4184;
    map.energy.kWh = 3.6e6;
    map.energy.eV = 1.602e-19;
    map.energy.BTU = 1055.06;

    % 功率 (相对于瓦特)
    map.power.W = 1;
    map.power.kW = 1000;
    map.power.MW = 1e6;
    map.power.hp = 745.7;
    map.power.BTU_h = 0.293071;

    % 力 (相对于牛顿)
    map.force.N = 1;
    map.force.kN = 1000;
    map.force.lbf = 4.44822;
    map.force.dyn = 1e-5;
    map.force.kgf = 9.80665;

    % 速度 (相对于 m/s)
    map.velocity.ms = 1;
    map.velocity.kmh = 0.277778;
    map.velocity.mph = 0.44704;
    map.velocity.knot = 0.514444;
    map.velocity.fps = 0.3048;

    % 面积 (相对于 m²)
    map.area.m2 = 1;
    map.area.cm2 = 1e-4;
    map.area.mm2 = 1e-6;
    map.area.ft2 = 0.092903;
    map.area.in2 = 6.4516e-4;
    map.area.acre = 4046.86;

    % 体积 (相对于 m³)
    map.volume.m3 = 1;
    map.volume.L = 0.001;
    map.volume.mL = 1e-6;
    map.volume.gal = 0.00378541;
    map.volume.ft3 = 0.0283168;
    map.volume.in3 = 1.6387e-5;

    % 角度
    map.angle.deg = pi/180;
    map.angle.rad = 1;

    % 频率 (相对于 Hz)
    map.frequency.Hz = 1;
    map.frequency.kHz = 1000;
    map.frequency.MHz = 1e6;
    map.frequency.GHz = 1e9;
    map.frequency.rpm = 1/60;
end
