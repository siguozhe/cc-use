#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Convert Markdown files to PDF with Chinese support."""

import argparse
import markdown2
from weasyprint import HTML, CSS
from pathlib import Path

# CSS styling with Chinese font support
css_content = """
@page {
    size: A4;
    margin: 2cm;
}
body {
    font-family: 'WenQuanYi Micro Hei', 'WenQuanYi Zen Hei', 'AR PL UMing CN', 'Microsoft YaHei', 'Noto Sans CJK SC', 'SimHei', sans-serif;
    font-size: 11pt;
    line-height: 1.6;
    color: #333;
}
h1 {
    color: #1a5490;
    border-bottom: 2px solid #1a5490;
    padding-bottom: 10px;
    margin-top: 10px;
    font-family: 'WenQuanYi Micro Hei', 'WenQuanYi Zen Hei', 'AR PL UMing CN', 'Microsoft YaHei', 'Noto Sans CJK SC', 'SimHei', sans-serif;
}
h2 {
    color: #2c3e50;
    margin-top: 20px;
    margin-bottom: 10px;
    font-family: 'WenQuanYi Micro Hei', 'WenQuanYi Zen Hei', 'AR PL UMing CN', 'Microsoft YaHei', 'Noto Sans CJK SC', 'SimHei', sans-serif;
    page-break-before: auto;
    page-break-after: avoid;
}
h3 {
    color: #34495e;
    margin-top: 15px;
    margin-bottom: 8px;
    font-family: 'WenQuanYi Micro Hei', 'WenQuanYi Zen Hei', 'AR PL UMing CN', 'Microsoft YaHei', 'Noto Sans CJK SC', 'SimHei', sans-serif;
    page-break-after: avoid;
}
h4 {
    color: #5a6c7d;
    margin-top: 12px;
    margin-bottom: 6px;
    font-family: 'WenQuanYi Micro Hei', 'WenQuanYi Zen Hei', 'AR PL UMing CN', 'Microsoft YaHei', 'Noto Sans CJK SC', 'SimHei', sans-serif;
}
table {
    border-collapse: collapse;
    width: 100%;
    margin: 15px 0;
    font-size: 0.95em;
}
th, td {
    border: 1px solid #ddd;
    padding: 8px 12px;
    text-align: left;
}
th {
    background-color: #1a5490;
    color: white;
    font-weight: bold;
    font-family: 'WenQuanYi Micro Hei', 'WenQuanYi Zen Hei', 'AR PL UMing CN', 'Microsoft YaHei', 'Noto Sans CJK SC', 'SimHei', sans-serif;
}
tr:nth-child(even) {
    background-color: #f9f9f9;
}
strong, b {
    color: #1a5490;
    font-weight: bold;
}
code {
    background-color: #f8f9fa;
    padding: 2px 6px;
    border-radius: 3px;
    font-family: 'WenQuanYi Micro Hei Mono', 'Courier New', 'AR PL UMing CN', 'SimSun', monospace;
    font-size: 0.9em;
    color: #c7254e;
}
pre {
    background-color: #f8f9fa;
    padding: 12px;
    border-radius: 8px;
    border: 1px solid #e9ecef;
    overflow-x: auto;
    page-break-inside: avoid;
}
pre code {
    background-color: transparent;
    padding: 0;
    font-family: 'WenQuanYi Micro Hei Mono', 'Courier New', 'AR PL UMing CN', 'SimSun', monospace;
    font-size: 0.9em;
    color: #333;
}
ul, ol {
    margin: 10px 0;
    padding-left: 25px;
}
li {
    margin: 5px 0;
    line-height: 1.6;
}
a {
    color: #1a5490;
    text-decoration: underline;
}
blockquote {
    border-left: 4px solid #1a5490;
    padding-left: 15px;
    margin: 15px 0;
    color: #666;
}
hr {
    border: none;
    border-top: 1px solid #ddd;
    margin: 20px 0;
}
"""

def convert_md_to_pdf(md_file, output_file=None, title=None, author=None):
    """Convert a single Markdown file to PDF."""
    md_path = Path(md_file)
    if not md_path.exists():
        print("File not found: {}".format(md_file))
        return False

    # Read Markdown
    md_content = md_path.read_text(encoding='utf-8')

    # Convert to HTML with full markdown support
    html_content = markdown2.markdown(
        md_content,
        extras=[
            'tables',           # 表格支持
            'fenced-code-blocks', # 代码块
            'code-friendly',     # 代码友好
            'header-ids',       # 标题ID
            'toc',              # 目录
            'footnotes',        # 脚注
            'smart-lists',      # 智能列表
            'metadata',         # 元数据
            'wiki-tables'      # Wiki表格
        ]
    )

    # Create full HTML document
    html_template = '<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body>{body}</body></html>'
    html = html_template.format(body=html_content)

    # Determine output file
    if output_file:
        pdf_path = Path(output_file)
    else:
        pdf_path = md_path.with_suffix('.pdf')

    # Generate PDF
    html_obj = HTML(string=html)
    css_obj = CSS(string=css_content)
    html_obj.write_pdf(str(pdf_path), stylesheets=[css_obj])
    print("Successfully converted: {} -> {}".format(md_file, pdf_path))
    return True

def main():
    parser = argparse.ArgumentParser(description='Convert Markdown files to PDF with Chinese support.')
    parser.add_argument('input', help='Input Markdown file')
    parser.add_argument('-o', '--output', help='Output PDF file')
    parser.add_argument('--title', help='Document title (for metadata)')
    parser.add_argument('--author', help='Document author (for metadata)')

    args = parser.parse_args()

    convert_md_to_pdf(args.input, args.output, args.title, args.author)

if __name__ == '__main__':
    main()
