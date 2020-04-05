classdef Nation < handle
    
    properties
        info
        shape
        pop_density
    end
    
    methods 
        function plot(this,ax)
            arguments
                this
                ax matlab.graphics.axis.Axes = this.CreateNewAxes();
            end
            ax.NextPlot = 'add';
            axis square
            mapshow(ax,this.shape.X,this.shape.Y);
            geoshow(ax,this.pop_density.A,this.pop_density.R,'DisplayType','surface');
        end
        
        function [B,RB] = findPopulationDensityData( this )
            [A,RA] = this.ReadPopulationDensityData();
            ylimits = this.shape.BoundingBox(:,1);
            xlimits = this.shape.BoundingBox(:,2);
            [B,RB] = geocrop(A,RA,xlimits,ylimits);
            B(B < -1e9) = nan;
            this.pop_density.A = B; 
            this.pop_density.R = RB;
        end
    end
    
    methods (Static)
        function ax = CreateNewAxes()
            fig = figure;
            ax = axes;
        end
        function obj = FindNation( name,value )
            arguments (Repeating)
                name string
                value
            end
            [S,A] = Nation.ReadNationalIdentifierFile();
            
            ix = 1:length(A);
            for ii = 1:numel(name)
                n = name{ii};
                v = value{ii};
                if any(strcmp(fieldnames(A), n))
                    ix = ix & strcmp({A.(n)},v);
                end
            end
            N = find(ix);
            rows = A(N,:);
            assert( numel(rows) > 0,'Cannot match inputs' );
            assert( numel(rows) < 2,'Found mutiple matches' );
            
            info = rows;
            shape = S(N);
            
            obj = Nation;
            obj.info = info;
            obj.shape = shape;
            obj.findPopulationDensityData();
        end
        function [S,A] = ReadNationalIdentifierFile()
            persistent s
            persistent a
            if isempty(s)
                foldername = fullfile(pwd,"national-identifier");
                shapefile = fullfile(foldername,"gpw_v4_national_identifier_grid_rev11_15_min.shp");
                [s,a] = shaperead(shapefile);                
            end
            S = s; A = a;
        end
        function [A,R] = ReadPopulationDensityData()
            persistent a
            persistent r
            if isempty(a)
                filename = fullfile(pwd,'population-density','gpw-v4-population-count_2020.tif');
                [a,r] = readgeoraster(filename);                
            end
            A = a; R = r;
        end
    end
    
end