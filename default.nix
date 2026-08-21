{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation {
  pname = "wuespace-plymouth-theme";
  version = "0.1.0";
  src = ./.;

  nativeBuildInputs = [
    pkgs.imagemagick
    pkgs.glaxnimate
  ];

  dontWrapQtApps = true;

  buildPhase = ''
    mkdir -p assets

    # Render all 180 frames from Glaxnimate vector file headlessly
    QT_QPA_PLATFORM=offscreen glaxnimate wuespace_animation.rawr -r assets/frame_.png --frame all

    # glaxnimate zero-pads its render output (frame_000.png ...), but the
    # Plymouth script builds frame names by concatenation, so strip the padding.
    num_frames=0
    for f in assets/frame_*.png; do
      n=''${f##*/frame_}
      t="assets/frame_$((10#''${n%.png})).png"
      [ "$f" = "$t" ] || mv "$f" "$t"
      num_frames=$((num_frames + 1))
    done

    # Automatically detect animation frame size and render static SVG to match
    frame_size=$(magick "assets/frame_0.png" -format "%wx%h" info:)
    magick -background none static.svg -resize "$frame_size" assets/static.png

    # Diagonal background gradient: BG1 #1E1E2E -> BG2 #182D4A, interpolated in
    # Oklab 
    # Rendered at 1080p; wuespace.script scales it to the real display size.
    bg_start=$(magick xc:"#1E1E2E" -colorspace Oklab txt: | tail -1 | grep -o '#[0-9A-F]*')
    bg_end=$(magick xc:"#182D4A" -colorspace Oklab txt: | tail -1 | grep -o '#[0-9A-F]*')
    magick -size 1920x1080 xc: -colorspace Oklab \
      -sparse-color barycentric "0,0 $bg_start 1919,1079 $bg_end" \
      -colorspace sRGB -ordered-dither o8x8,256 -depth 8 assets/background.png
  '';

  installPhase = ''
    mkdir -p $out/share/plymouth/themes/wuespace
    cp -r assets/* $out/share/plymouth/themes/wuespace/
    cp wuespace.script $out/share/plymouth/themes/wuespace/
    cp wuespace.plymouth $out/share/plymouth/themes/wuespace/

    substituteInPlace $out/share/plymouth/themes/wuespace/wuespace.plymouth \
      --subst-var out

    substituteInPlace $out/share/plymouth/themes/wuespace/wuespace.script \
      --subst-var num_frames
  '';
}
