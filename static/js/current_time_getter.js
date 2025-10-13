function padZero(num) {
    return num < 10 ? '0' + num : num;
}


function getCurrentTime() {
    const now = new Date();
    const utcMilliseconds = now.getTime();
    const threeHoursInMs = 3 * 60 * 60 * 1000;
    const utcPlus3Milliseconds = utcMilliseconds + threeHoursInMs;
    const dateUtcPlus3 = new Date(utcPlus3Milliseconds);
    const hours = dateUtcPlus3.getUTCHours();
    const minutes = dateUtcPlus3.getUTCMinutes();
    const seconds = dateUtcPlus3.getUTCSeconds();
    return `${padZero(hours)}:${padZero(minutes)}:${padZero(seconds)}`;
}