
from datetime import datetime
from functools import wraps
from io import StringIO
from os import makedirs
from os.path import basename, dirname, join as pjoin
import traceback


OUTPUT_DIR = 'etl_output'


def _etl_timestamp():
    return datetime.now().strftime('%Y-%m-%d %H%M%S.%f')[:-3]


def etl_printer(func):
    @wraps(func)
    def wrapper(processor, *args, **kwargs):
        processor.pr(func.__name__, 'STARTED', _etl_timestamp())
        try:
            result = func(processor, *args, **kwargs)
        except Exception as exc:
            processor.pre(func.__name__, traceback.format_exc())
            raise exc
        processor.pr(func.__name__, 'COMPLETED', _etl_timestamp())
        return result

    return wrapper


class EtlProcessor:
    def __init__(self, name=None, args=None, python_file=None):
        self.name = name
        self._args = args
        self.python_file = python_file or __file__
        self._output_file = pjoin(
            OUTPUT_DIR,
            f'{basename(self.python_file).removesuffix(".py")}.txt',
        )
        self._buffer = StringIO()

    @property
    def args(self):
        return self._args

    @property
    def output_file(self):
        return self._output_file

    @property
    def buffer(self):
        return self._buffer

    def pr(self, *args, **kwargs):
        kwargs.update({'flush': True, 'file': self.buffer})
        print(*args, **kwargs)

    def pre(self, *args, **kwargs):
        kwargs.update({'flush': True, 'file': self.buffer})
        print('ERROR:', *args, **kwargs)

    def post_process(self):
        output_dir = dirname(self.output_file)
        if output_dir:
            makedirs(output_dir, exist_ok=True)
        with open(self.output_file, 'w', encoding='utf-8') as output_handle:
            output_handle.write(self.buffer.getvalue())