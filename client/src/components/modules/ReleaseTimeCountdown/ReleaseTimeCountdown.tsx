import { Box, Text, VStack } from '@chakra-ui/react';
import { useEffect, useState } from 'react';

interface Props {
    releaseTimestamp: number,
}

function d(time: number) {
    return Math.floor(time / 86400)
}

function h(time: number) {
    return Math.floor(((time - d(time) * 86400)) / 3600)
}

function m(time: number) {
    return Math.floor(((time - d(time) * 86400 - h(time) * 3600)) / 60)
}

function s(time: number) {
    return (time - d(time) * 86400 - h(time) * 3600 - m(time) * 60)
}

const ReleaseTimeCountdown = ({ releaseTimestamp }: Props) => {
    const [time, setTime] = useState<number>(0);
    useEffect(() => {
        const interval = setInterval(() => setTime(releaseTimestamp - Math.floor((Date.now() / 1000))), 1000);
        return () => {
            clearInterval(interval);
        };
    }, [releaseTimestamp])
    return (
        <Box my={'30px'}>
            <Text align='center'>{`Release time: ${releaseTimestamp} | ${new Date(releaseTimestamp * 1000).toLocaleString()}`}</Text>
            {(time <= 0) ? <Text align='center' color='red.600' mt={4}>
                <Text as={'b'}>
                RELEASABLE
                </Text>
            </Text> :
                <VStack>
                    <Text align='center'>
                        Time left untill release:
                    </Text>

                    <Text align='center' color='red.600' variant='h4'>
                        {d(time)} d / {h(time)} h / {m(time)} m / {s(time)} s
                    </Text>
                </VStack>
            }
        </Box >
    )
}

export default ReleaseTimeCountdown