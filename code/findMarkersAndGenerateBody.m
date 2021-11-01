function [body, indexMarkers] = findMarkersAndGenerateBody(ii4, nameMarkers, bodyParts)
% Construct the body and the index of the markers.
% The body is a structure containing the markers of each body-part.
% and indexMarkers is the relation between marker name and number
%
% OUTPUT
% body: Body-parts with indexes
% indexMarkers: Struct with relation between marker name and number

    arguments
        % name af all the markers in the trc file
        ii4 string
        % name of the markers that im searching for
        nameMarkers (1, :)
        % struct contaning the name of the body part and the markers that
        % belongs to that part
        bodyParts (1, :) struct
    end
    
    indexMarkers = struct();
    for name=nameMarkers
        position = (find(name == ii4)-2)*3;
        indexMarkers.(name) = position;
    end

    body = struct();
    for bodyPart=bodyParts
        len = length(bodyPart.mks);
        positions = zeros(1, len);
        for i=1:len
            positions(i) = indexMarkers.(bodyPart.mks(i));
        end
        body.(bodyPart.name) = positions;
    end
end