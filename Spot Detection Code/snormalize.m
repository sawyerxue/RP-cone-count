function J = snormalize(I)
    J = I-mean(I(:));
    J = J/std(J(:));
end