import json
import os
from flask import Flask, Response, abort
from .utils import JSON_MIME_TYPE, search_book
BOOKTITLE = os.getenv('BOOKTITLE')

app = Flask(__name__)

books = [{
    'id': 33,
    'title': BOOKTITLE,
    'author_id': 1
}]


@app.route('/book')
def book_list():
    response = Response(
        json.dumps(books), status=200, mimetype=JSON_MIME_TYPE)
    return response


@app.route('/book/<int:book_id>')
def book_detail(book_id):
    book = search_book(books, book_id)
    #book['title'] = BOOK_TITLE
    if book is None:
        abort(404)

    content = json.dumps(book)
    return content, 200, {'Content-Type': JSON_MIME_TYPE}


@app.errorhandler(404)
def not_found(e):
    return '', 404
