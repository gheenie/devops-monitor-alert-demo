"""Runs randomly erroring code with a time delay."""
from random import randint, uniform
import logging
import time

logger = logging.getLogger('MistakerLogger')
logger.setLevel(logging.INFO)


class MultipleOfThreeError(Exception):
    """Raised on multiple of three being generated."""
    pass


def lambda_handler(event, context):
    """Runs randomly erroring process on a time delay.

    The process will be delayed between 300 and 500 milliseconds.

    Returns:
        None

    Raises:
        MultipleOfThreeError
    """
    number = randint(1, 100)
    sleep_time = uniform(0.3, 0.5)
    time.sleep(sleep_time)
    if number % 3 == 0:
        logger.warning(f'Oh no {number} is divisible by 3')
        raise MultipleOfThreeError
    else:
        logger.info(f'Yawn. {number} is a pretty boring number')
