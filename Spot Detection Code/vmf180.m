function [c,l] = vmf180(V,k)
    % Von Mises-Fisher Mean Shift for Clustering on a Hypersphere
    % T. Kobayashi and N. Otsu, "Von Mises-Fisher Mean Shift for Clustering on a Hypersphere,"
    % Pattern Recognition (ICPR), 2010 20th International Conference on, Istanbul, 2010, pp. 2130-2133.

    [n,d] = size(V);
    K = @(x,x0) exp(k*dot(x,x0)); % kernel

    C = zeros(n,d); % convergence points for every sample
    for i = 1:n
        m = V(i,:);

        previousm = -m;
        while dot(previousm,m) < 0.999999
            previousm = m;

            M = zeros(1,d);
            
            nbh = find(sum(V.*repmat(m,[n 1]),2) > 0.7);
            
            for jj = 1:length(nbh)
                j = nbh(jj);
                M = M+K(V(j,:),m)*V(j,:);
            end
            
            m = M/norm(M);
        end

        C(i,:) = m;
    end

    for i = 1:size(C,1)
        if C(i,2) < 0
            C(i,:) = -C(i,:);
        end
    end
    
    c = C(1,:); % convergence points (one per cluster)
    l = zeros(n,1); % cluster labels (one per sample)
    for i = 1:n
        didbreak = 0;
        for j = 1:size(c,1)
            if dot(C(i,:),c(j,:)) > 0.999
                l(i) = j;
                didbreak = 1;
                break;
            end
        end
        if ~didbreak
            c = [c; C(i,:)];
            l(i) = size(c,1);
        end
    end
end