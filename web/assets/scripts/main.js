((select, haml) => {
  if (!select || !haml) return;

  const HIDDEN_CLASS = 'hidden';
  const TIMEOUT_ATTRIBUTE = 'data-timeout';
  const HASH_ATTRIBUTE = 'data-hash';

  const label = document.getElementById('with-erb');
  const erb = document.getElementById('erb');
  const converter = document.getElementById('converter');

  const ajaxConvert = ({ timeout = 250 }) => {
    if (!haml.value) return;
    clearTimeout(+haml.getAttribute(TIMEOUT_ATTRIBUTE));
    haml.setAttribute(TIMEOUT_ATTRIBUTE, setTimeout(() => {
      const savedHash = +haml.getAttribute(HASH_ATTRIBUTE);
      const currentHash = Array.from((haml.value + converter.value))
        .map(chr => chr.charCodeAt())
        .reduce((hash, code) => ((hash * 31) + (2 * code)) | 0, 0); // eslint-disable-line
      if (savedHash === currentHash) return;
      const form = new FormData();
      form.append('haml', haml.value);
      form.append('converter', converter.value);

      fetch('/api/convert', {
        method: 'POST',
        headers: { Accept: 'application/json' },
        body: form,
      }).then((response) => {
        if (response.status === 200) return response;
        const error = new Error(response.statusText);
        error.response = response;
        throw error;
      }).then(response => response.json())
        .then((json) => {
          erb.value = json.erb;
          haml.setAttribute(HASH_ATTRIBUTE, currentHash);
        })
        .catch(error => error.response.json().then(json => (erb.value = json.error)));
    }, timeout));
  };

  select.addEventListener('change', () => {
    ajaxConvert({ timeout: 0 });
    if (converter.value === 'haml_gem') {
      label.classList.add(HIDDEN_CLASS);
    } else {
      label.classList.remove(HIDDEN_CLASS);
    }
  });

  haml.addEventListener('input', ajaxConvert);
})(document.getElementById('converter'), document.getElementById('haml'));
