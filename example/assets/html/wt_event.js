const WTEventType = Object.freeze({
    DEFAULT: 'DEFAULT',
    REVENUE: 'REVENUE'
});

const RevenueCurrency = Object.freeze({
    USD: 'USD',
    EUR: 'EUR',
    JPY: 'JPY',
    GBP: 'GBP',
    AUD: 'AUD',
    CAD: 'CAD',
    CHF: 'CHF',
    CNY: 'CNY',
    SEK: 'SEK',
    NZD: 'NZD',
    MXN: 'MXN',
    SGD: 'SGD',
    HKD: 'HKD',
    NOK: 'NOK',
    KRW: 'KRW',
    TRY: 'TRY',
    RUB: 'RUB',
    INR: 'INR',
    BRL: 'BRL',
    ZAR: 'ZAR',
    IRR: 'IRR',
    AED: 'AED',
    IQD: 'IQD',
    SAR: 'SAR',
    OMR: 'OMR',
    BTC: 'BTC',
    EHT: 'EHT',
    LTC: 'LTC'
});

class WTEvent {
    constructor(name, type) {
        if (typeof name !== 'string' || name.trim() === '') {
            throw new Error('[WiseTrack]: Event name must be a non-empty string');
        }
        if (!Object.values(WTEventType).includes(type)) {
            throw new Error('[WiseTrack]: Invalid event type');
        }

        this.name = name;
        this.type = type;
        this.params = {};
        this.revenue = null;
        this.currency = null;
    }

    setRevenue(amount, currency) {
        if (this.type !== WTEventType.REVENUE) {
            throw new Error('[WiseTrack]: Revenue can only be set for REVENUE events');
        }
        if (typeof amount !== 'number' || amount < 0) {
            throw new Error('[WiseTrack]: Revenue amount must be a non-negative number');
        }
        if (!Object.values(RevenueCurrency).includes(currency)) {
            throw new Error('[WiseTrack]: Invalid currency');
        }
        this.revenue = amount;
        this.currency = currency;
        return this;
    }

    addParam(key, value) {
        if (typeof key !== 'string' || key.trim() === '') {
            throw new Error('[WiseTrack]: Parameter key must be a non-empty string');
        }
        if (typeof value === 'string' || typeof value === 'number' || typeof value === 'boolean') {
            this.params[key] = value;
        } else {
            throw new Error('[WiseTrack]: Parameter value must be a string, number, or boolean');
        }
        return this;
    }

    toJSON() {
        return {
            type: this.type,
            name: this.name,
            revenue: this.revenue,
            currency: this.currency,
            params: this.params
        };
    }

    static defaultEvent(name) {
        return new WTEvent(name, WTEventType.DEFAULT);
    }

    static revenueEvent(name, amount, currency) {
        var event = new WTEvent(name, WTEventType.REVENUE);
        event.setRevenue(amount, currency);
        return event;
    }
}