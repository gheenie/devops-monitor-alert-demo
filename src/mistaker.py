from random import randint
import logging

logger = logging.getLogger('MistakerLogger')
logger.setLevel(logging.INFO)


class MultipleOfThreeError(Exception):
    pass


def lambda_handler(event, context):
    number = randint(1, 100)
    if number % 3 == 0:
        logger.warning(f'Oh no {number} is divisible by 3')
        raise MultipleOfThreeError
    else:
        logger.info(f'Yawn. {number} is a pretty boring number')
