from random import randint
import logging
from unittest.mock import patch
import pytest

logger = logging.getLogger('MistakerLogger')
logger.setLevel(logging.INFO)


class MultipleOfFiveError(Exception):
    pass


def lambda_handler(event, context):
    number = randint(1, 100)
    if number % 5 == 0:
        logger.warning(f'Oh no {number} is divisible by 5')
        raise MultipleOfFiveError
    else:
        logger.info(f'Yawn. {number} is a pretty boring number')


def test_lambda_throws_correct_error_if_number_is_multiple_of_five():
    with patch('mistaker.randint', return_value=15) as m:
        with pytest.raises(MultipleOfFiveError):
            lambda_handler({}, {})


def test_lambda_logs_message_if_number_is_a_multiple_of_five(caplog):
    with patch('mistaker.randint', return_value=25):
        try:
            lambda_handler({}, {})
        except MultipleOfFiveError:
            with caplog.at_level(logging.INFO):
                assert ('Oh no 25 is divisible by 5'
                    in caplog.text)


def test_lambda_logs_message_if_number_not_a_multiple_of_five(caplog):
    with patch('mistaker.randint', return_value=29):
        with caplog.at_level(logging.INFO):
            lambda_handler({}, {})
            assert ('Yawn. 29 is a pretty boring number'
                in caplog.text)