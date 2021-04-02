function imshowlinkedquartet(I,J,K,L,titles)
    scsz = get(0,'ScreenSize'); % scsz = [left botton width height]
    figure('Position',[scsz(3)/4 scsz(4)/4 scsz(3)/2 scsz(4)/2])

    ax1 = subplot(1,4,1);
    imshow(I)
    if nargin > 4
        title(titles{1})
    end

    ax2 = subplot(1,4,2);
    imshow(J)
    if nargin > 4
        title(titles{2})
    end
    
    ax3 = subplot(1,4,3);
    imshow(K)
    if nargin > 4
        title(titles{3})
    end
    
    ax4 = subplot(1,4,4);
    imshow(L)
    if nargin > 4
        title(titles{4})
    end

    linkaxes([ax1,ax2,ax3,ax4],'xy')
end