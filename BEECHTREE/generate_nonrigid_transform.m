function tform_dat = generate_nonrigid_transform(thermImRGB, visPts, thermPts)
%%
resize_factor = 1/6.5;
%visIm_rs = imresize(visIm, resize_factor);
visPts_rs = visPts*resize_factor;
[O_trans,Spacing]=point_registration(size(thermImRGB)*1.2,visPts_rs,thermPts);
tform_dat.O_trans = O_trans;
tform_dat.Spacing = Spacing;

plt = 0;

if plt == 1
    out = bspline_trans_points_double(tform_dat.O_trans, tform_dat.Spacing, visPts_rs);
    offset = 20;
    
    out1 = bspline_trans_points_double(tform_dat.O_trans, tform_dat.Spacing, visPts_rs+offset);
    out2 = bspline_trans_points_double(tform_dat.O_trans, tform_dat.Spacing, visPts_rs-offset);
    
    imshow(thermImRGB);
    hold on
    plot(thermPts(:,1), thermPts(:,2), 'b.');
    plot(out(:,1), out(:,2), 'go');
    plot(out1(:,1), out1(:,2), 'g.');
    plot(out2(:,1), out2(:,2), 'g.');
end