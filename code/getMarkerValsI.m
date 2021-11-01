function XYZ = getMarkerValsI(m_cols, idx, i)
% Return the x, y and z value of a marker at time i.
%
% OUTPUT:
% XYZ: x, y and z value of a marker at time i

    arguments
        % Matrix containig the data of the markers at time i
        m_cols (:, :) {}
        % Index of the marker
        idx {mustBeNumeric}
        % Markers at time i
        i {mustBeNumeric}
    end
    
    XYZ = [m_cols(i, idx+0), m_cols(i, idx+1), m_cols(i, idx+2)];
end