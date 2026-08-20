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

    # Render animation frames headlessly from Glaxnimate vector file
    QT_QPA_PLATFORM=offscreen glaxnimate wuespace_animation.rawr -r /tmp/raw_frames/f.png --frame all

    # Pick every 5th frame (from 0 to 175) for a smooth 36-frame loop
    i=0
    for f in $(seq 0 5 175); do
      printf -v srcname "/tmp/raw_frames/f%03d.png" $f
      printf -v dstname "assets/frame_%02d.png" $i
      cp "$srcname" "$dstname"
      i=$((i + 1))
    done
    num_frames=$i

    # Automatically detect animation frame size and render static SVG to match
    frame_size=$(magick "assets/frame_00.png" -format "%wx%h" info:)
    magick -background none static.svg -resize "$frame_size" assets/static.png

    # Create bullet dot for password prompt
    magick -size 16x16 xc:none -fill "#ffffff" -draw "circle 8,8 8,14" assets/bullet.png

    # Create colored brackets [#F9A877] for password prompt
    magick -size 10x24 xc:none -stroke "#F9A877" -strokewidth 2 -fill none -draw "polyline 8,2 2,2 2,22 8,22" assets/bracket_left.png
    magick -size 10x24 xc:none -stroke "#F9A877" -strokewidth 2 -fill none -draw "polyline 2,2 8,2 8,22 2,22" assets/bracket_right.png
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
