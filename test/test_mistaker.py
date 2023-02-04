import pytest
from unittest.mock import patch
from src.mistaker import lambda_handler, MultipleOfThreeError
import logging


def test_lambda_throws_correct_error_if_number_is_multiple_of_three():
    with patch('src.mistaker.randint', return_value=15):
        with pytest.raises(MultipleOfThreeError):
            lambda_handler({}, {})


def test_lambda_logs_message_if_number_is_a_multiple_of_three(caplog):
    with patch('src.mistaker.randint', return_value=21):
        try:
            lambda_handler({}, {})
            pytest.fail('The lambda did not throw an error')
        except MultipleOfThreeError:
            with caplog.at_level(logging.INFO):
                assert ('Oh no 21 is divisible by 3'
                        in caplog.text)


def test_lambda_logs_message_if_number_not_a_multiple_of_three(caplog):
    with patch('src.mistaker.randint', return_value=29):
        with caplog.at_level(logging.INFO):
            lambda_handler({}, {})
            assert ('Yawn. 29 is a pretty boring number'
                    in caplog.text)
