function [radRowCol,spotsCoord] = Headless(I,prmts)
    [radRowCol,spotsCoord] = fitCircleAndDetectSpots(I,prmts.FgThr,prmts.EstRad,prmts.ResFac,prmts.Sigma,prmts.LoGThr,false);
end