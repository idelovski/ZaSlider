CATransform3D  scalingTransform = CATransform3DIdentity;

rotationTransform = CATransform3DScale (scalingTransform, 1.f, 0.8f, 1.f);

self.arrowView.layer.transform = scalingTransform;


gGPrefsRec.pfShowNumbers

CGAffineTransform transform = CGAffineTransformMakeScale (1., 1.);
