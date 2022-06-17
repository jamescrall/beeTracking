function [thermPtsBase visPtsBase] = refineRegistrationControlPoints(thermPtsBase,visPtsBase, thermImRGB, visIm)


                    [thermPtsBase visPtsBase] = cpselect(thermImRGB, visIm,thermPtsBase, visPtsBase, 'Wait', true)
