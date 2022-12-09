import pytest
from unittest.mock import patch
from mistaker import lambda_handler, MultipleOfFiveError
import logging


def test_lambda_throws_correct_error_if_number_is_multiple_of_five():
    with patch('mistaker.randint', return_value=15):
        with pytest.raises(MultipleOfFiveError):
            lambda_handler({}, {})


def test_lambda_logs_message_if_number_is_a_multiple_of_five(caplog):
    with patch('mistaker.randint', return_value=25):
        try:
            lambda_handler({}, {})
            pytest.fail('The lambda did not throw an error')
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
