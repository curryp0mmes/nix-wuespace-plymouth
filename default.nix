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
    mkdir -p assets /tmp/raw_frames

    # Render all 180 frames from Glaxnimate vector file headlessly
    QT_QPA_PLATFORM=offscreen glaxnimate wuespace_animation.rawr -r /tmp/raw_frames/f.png --frame all

    # Copy all frames sequentially into assets
    i=0
    for f in $(ls -1 /tmp/raw_frames/f*.png | sort); do
      cp "$f" "assets/frame_$i.png"
      i=$((i + 1))
    done
    num_frames=$i

    # Automatically detect animation frame size and render static SVG to match
    frame_size=$(magick "assets/frame_0.png" -format "%wx%h" info:)
    magick -background none static.svg -resize "$frame_size" assets/static.png

    # Create bullet dot for password prompt
    magick -size 16x16 xc:none -fill "#ffffff" -draw "circle 8,8 8,14" assets/bullet.png
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
