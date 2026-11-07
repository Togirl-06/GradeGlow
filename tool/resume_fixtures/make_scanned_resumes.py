"""Builds the scanned-resume test fixtures from grace_kim_biology.docx.

Renders the resume text to a page picture (like a scanner would), then:
  grace_kim_scan_jpeg.pdf   a JPEG scan inside a PDF (DCTDecode)
  grace_kim_scan_gray.pdf   a greyscale PNG scan inside a PDF (Flate + PNG predictor)
  grace_kim_scan_fax.pdf    a black-and-white fax-compressed scan (CCITT G4)
  grace_kim_photo.jpg       a phone photo of the page
  grace_kim_scan.txt        the text on the page (what a perfect reader returns)
Run: python3 tool/resume_fixtures/make_scanned_resumes.py  (needs Pillow, img2pdf, python-docx)
"""
import io, os
import docx, img2pdf
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, '..', '..', 'test', 'fixtures', 'resumes')
lines = [p.text for p in docx.Document(os.path.join(OUT, 'grace_kim_biology.docx')).paragraphs]
lines = [l for l in lines if l.strip()]

W, H = 1275, 1650  # US Letter at 150 dpi
font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 22)
bold = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 26)
page = Image.new('L', (W, H), 255)
d = ImageDraw.Draw(page)
y = 90
out_lines = []
for i, l in enumerate(lines):
    f = bold if (i == 0 or l.isupper() or len(l) < 22) else font
    words, cur = l.split(), ''
    wrapped = []
    for w in words:
        t = (cur + ' ' + w).strip()
        if d.textlength(t, font=f) > W - 180:
            wrapped.append(cur); cur = w
        else:
            cur = t
    wrapped.append(cur)
    for wl in wrapped:
        d.text((90, y), wl, font=f, fill=20)
        y += 36
    out_lines.append(l)
    y += 8
assert y < H - 60, 'text does not fit on one page'
open(os.path.join(OUT, 'grace_kim_scan.txt'), 'w').write('\n'.join(out_lines) + '\n')

def save_pdf(img_bytes, name):
    with open(os.path.join(OUT, name), 'wb') as fh:
        fh.write(img2pdf.convert(img_bytes, layout_fun=img2pdf.get_fixed_dpi_layout_fun((150, 150))))

b = io.BytesIO(); page.save(b, 'JPEG', quality=70); save_pdf(b.getvalue(), 'grace_kim_scan_jpeg.pdf')
b = io.BytesIO(); page.save(b, 'PNG', optimize=True); save_pdf(b.getvalue(), 'grace_kim_scan_gray.pdf')
b = io.BytesIO(); page.convert('1').save(b, 'TIFF', compression='group4'); save_pdf(b.getvalue(), 'grace_kim_scan_fax.pdf')
photo = page.convert('RGB').rotate(1.2, expand=True, fillcolor=(205, 200, 190)).resize((1000, 1300))
photo.save(os.path.join(OUT, 'grace_kim_photo.jpg'), 'JPEG', quality=72)
