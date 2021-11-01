classdef GapFiller
% This class manage the filling phase of the data
% it find the better grade for the polinomial to fit the data.

    properties
        % matrix containig the data of the markers over the time
        MC;
        % Flag, if true plot infos on stdOut
        plotFlag;
    end
    
    properties (Access = private)
        % max polinomial degree
        MaxDegree = 5;
        % min interval value
        MINI = 1;
        % max interval value
        MAXI;
        % lenght of the interval
        DIST = 42;
    end
    
    methods
        % Constructor
        function obj = GapFiller(MAXI, plotFlag)
            arguments
                % max interval value
                MAXI double {mustBePositive}
                % Flag, if true plot infos on stdOut
                plotFlag {} = false
            end

            obj.MAXI = MAXI;
            obj.plotFlag = plotFlag;
            warning('off', 'MATLAB:polyfit:RepeatedPointsOrRescale')
        end  % function GapFiller
        
        % 
        function [MC] = fill(obj, MC)
            % INPUT
            % MC: data' matrix

            % OUTPUT
            % MC: MC modified
            
            for marker = 1:size(MC, 2)-1
                % get the 'marker'-th line and find the position of nan elements
                appRow = find(isnan(MC(:, marker)));

                if not(isempty(appRow))
                    if (obj.plotFlag)
                        disp("Marker: "+num2str(marker));
                    end
                    % get the extremes of the interval
                    intervals = [0, find(diff(appRow)>1)', length(appRow)];
                    for k=2:length(intervals)
                        if (obj.plotFlag)
                            disp("Interval: "+num2str(appRow(intervals(k-1)+1))+" - "+num2str(appRow(intervals(k))));
                        end
                        % call the function to find the better grade and fill this gap
                        MC = obj.fillThisMarker(MC, marker, appRow(intervals(k-1)+1), appRow(intervals(k)));
                    end
                end
            end
        end % end function fill
    end % end methods
    
    methods (Access = private)
        function [MC] = fillThisMarker(obj, MC, marker, minInterval, maxInterval)
            % INPUT
            % MC: data' matrix
            % marker: markers' number
            % minInterval: first index of the gap
            % maxInterval: last index of the gap

            % OUTPUT
            % MC: MC modified
            
            % find MINI and MAXI
            if minInterval-(obj.DIST/2) < obj.MINI
                maxInterval = maxInterval+(obj.DIST-(minInterval-obj.MINI));
                minInterval = obj.MINI;
            elseif maxInterval+(obj.DIST/2) > obj.MAXI
                minInterval = minInterval-(obj.DIST-(obj.MAXI-maxInterval));
                maxInterval = obj.MAXI;
            else
                maxInterval = maxInterval+obj.DIST/2;
                minInterval = minInterval-obj.DIST/2;
            end
            
            if minInterval < obj.MINI
                minInterval = obj.MINI;
            end
            if maxInterval > obj.MAXI
                maxInterval = obj.MAXI;
            end
            
            % preallocating memory
            avgRes = zeros(1, obj.MaxDegree);
            % find the best grade
            try
                for i=1:obj.MaxDegree
                    avgRes(i) = obj.avgResiduals(MC(minInterval:maxInterval, :), marker, i);
                end
            catch ME
                rethrow(ME)
            end
            [~, maxPos] = max(avgRes);
            if (obj.plotFlag)
                disp("Grade: "+maxPos)
            end
            % call the function to fill
            MC(minInterval:maxInterval, marker) = obj.gapfilling(MC(minInterval:maxInterval, :), marker, maxPos);
        end % end function fillThisMarker
        
        function avgRes = avgResiduals(~, MC, id, grade)
            % INPUT
            % MC: data' matrix
            % id: markers' number
            % grade: polynomial grade
            % plt: true if i want to plot the data

            % OUTPUT
            % avgRes: residuals' average

            Marker = MC(:, id);
            Time = MC(:, 2);
            A = isnan(Marker);
            NN = find(A);
            Time (NN) = [];
            Marker(NN) = [];

            P_coeff = polyfit(Time, Marker, grade);
            res_P = Marker - polyval(P_coeff,Time);
            avgRes = mean(res_P);
        end % end function avgResiduals
        
        function [Marker] = gapfilling(~, MC, id, grade)
            % INPUT
            % MC: data' matrix
            % id: markers' number
            % grade: polynomial grade

            % OUTPUT
            % Marker: MC modified with the new data generated

            Marker = MC(:, id);
            Time = MC(:, 2);
            A = isnan(Marker);
            NN = find(A);
            Time (NN) = [];
            Marker(NN) = [];

            P_coeff = polyfit(Time, Marker, grade);
            Curve_fit = polyval(P_coeff, MC(:, 2));

            Marker = MC(:, id);
            Marker(NN) = Curve_fit(NN);
        end % end function gapfilling
        
    end % methods (Access = private)
end % classdef GapFiller