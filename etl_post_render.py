import sys
import os
import traceback
from io import StringIO
BUFFER = StringIO()
from bs4 import BeautifulSoup

def pr(*args, **kwargs):
    kwargs.update({'flush': True, 'file':BUFFER})
    print('&nbsp;', *args, **kwargs)
try:
    #data = '<br>'.join([line.strip() for line in sys.stdin.readlines()])
    html_parts = []
    if os.path.exists('etl_output'):
        for fname in [f for f in os.listdir('etl_output') if f.endswith('.txt')]:
            print(f'processing {fname}...', file=sys.stderr, flush=True)
            with open(os.path.join('etl_output', fname), 'r') as f:
                base_name = os.path.basename(fname).removesuffix('.txt')
                text = f.read()
                print(f'texts of {fname}:\n<BR>{text}', file=sys.stderr, flush=True)
                lines = [line.strip() for line in text.split('\n')]
                print(f'lines of {fname}:\n<BR>{lines}', file=sys.stderr, flush=True)
                contents = '<BR>\n&nbsp;&nbsp;'.join(lines)
                html_parts.extend([f'<h2>{base_name}</h2>', contents])
                pr(f'Contents of {fname}:\n{contents}', file=sys.stderr, flush=True)
    else:
        pr('No etl_output directory found.', file=sys.stderr, flush=True)
    pr(f'html_parts={html_parts}', file=sys.stderr, flush=True)
    print(f'html_parts={html_parts}', file=sys.stderr, flush=True)
    all_html = '\n&nbsp;<BR>&nbsp;&nbsp;'.join(html_parts)
    print(f'All HTML content:\n<BR>{all_html}', file=sys.stderr, flush=True)
    content_html = BeautifulSoup(all_html, 'html.parser')
    from bs4 import BeautifulSoup
    soup = BeautifulSoup(open('email-preview/index.html'), 'html.parser')
    body_tag = soup.body
    new_heading = soup.new_tag("h1", attrs={"id": "main_heading"})
    new_heading.string = f"SEC ETL Pipeline Ran Successfully" + "\n"
    body_tag.insert(0, new_heading) 
    h1 = soup.find('h1', id='main_heading')
    h1.insert_after(content_html)
    open('email-preview/index.html', 'wt').write(str(soup))
    open('etl_output/body.html', 'wt').write(str(content_html))
    pr('Successfully updated email-preview/index.html', file=sys.stderr, flush=True)
    # import os
    # os.system('say "beep"')
except Exception as e:
    print(f'Error in etl_post_render.py: {str(e)}\n{traceback.format_exc()}', file=sys.stderr, flush=True)
    open('junk.txt', 'at').write(f'Error updating email-preview/index.html: {str(e)}\n, {traceback.format_exc()}')
    pr(f'Error updating email-preview/index.html: {str(e)}', file=sys.stderr, flush=True)