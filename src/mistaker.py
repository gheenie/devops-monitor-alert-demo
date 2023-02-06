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

    The process will be delayed between 300 and 700 milliseconds.

    Returns:
        None

    Raises:
        MultipleOfThreeError
        RuntimeError
    """
    number = randint(1, 100)
    sleep_time = uniform(0.3, 0.7)
    time.sleep(sleep_time)
    if number % 3 == 0:
        logger.warning(f'Oh no {number} is a multiple of 3')
        raise MultipleOfThreeError
    elif number % 11 == 0:
        logger.error('No idea what just happened.')
        raise RuntimeError('Help!')
    else:
        logger.info(f'Yawn. {number} is a pretty boring number')
