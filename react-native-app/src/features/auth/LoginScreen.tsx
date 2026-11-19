import React, { useEffect, useState } from 'react';
import { Image, ScrollView, StyleSheet } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { AppText } from '../../core/components/AppText';
import { AppTextField } from '../../core/components/AppTextField';
import { PrimaryButton } from '../../core/components/PrimaryButton';
import { TextButton } from '../../core/components/TextButton';
import { AuthError, authErrorKey } from '../../data/repositories/authErrors';
import { theme } from '../../core/theme';
import type { AuthStackParamList } from '../../navigation/AuthStack';
import { useAuth } from './authController';
import { validateEmail, validatePassword } from './authValidation';

type Props = NativeStackScreenProps<AuthStackParamList, 'Login'>;
type FieldErrors = { email: AuthError | null; password: AuthError | null };

export function LoginScreen({ navigation }: Props): React.JSX.Element {
  const { signIn, isLoading, error, clearError } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [fieldErrors, setFieldErrors] = useState<FieldErrors>({
    email: null,
    password: null,
  });

  // Start without an error left over from the other auth screen.
  useEffect(() => {
    clearError();
  }, [clearError]);

  const submit = () => {
    if (isLoading) {
      return;
    }
    const errors = {
      email: validateEmail(email),
      password: validatePassword(password),
    };
    setFieldErrors(errors);
    if (errors.email || errors.password) {
      return;
    }
    signIn(email, password);
  };

  return (
    <ScrollView
      contentContainerStyle={styles.container}
      keyboardShouldPersistTaps="handled"
    >
      <Image
        source={require("../../../assets/logo.png")}
        style={styles.logo}
        resizeMode="contain"
      />
      <AppText translationKey="loginWelcomeTitle" style={styles.title} />
      <AppText
        translationKey="loginWelcomeSubtitle"
        style={styles.subtitle}
      />
      <AppTextField
        labelKey="authEmailLabel"
        errorKey={
          fieldErrors.email ? authErrorKey(fieldErrors.email) : undefined
        }
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
        autoCapitalize="none"
        autoCorrect={false}
        autoComplete="email"
        returnKeyType="next"
      />
      <AppTextField
        labelKey="authPasswordLabel"
        errorKey={
          fieldErrors.password ? authErrorKey(fieldErrors.password) : undefined
        }
        value={password}
        onChangeText={setPassword}
        secureTextEntry
        autoCapitalize="none"
        autoComplete="password"
        returnKeyType="done"
        onSubmitEditing={submit}
      />
      {error ? (
        <AppText
          translationKey={authErrorKey(error)}
          style={styles.formError}
        />
      ) : null}
      <PrimaryButton
        labelKey="authLoginButton"
        loading={isLoading}
        onPress={submit}
      />
      <TextButton
        labelKey="authGoToSignUp"
        disabled={isLoading}
        onPress={() => navigation.navigate('SignUp')}
      />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: theme.colors.background,
    flexGrow: 1,
    gap: theme.spacing.md,
    justifyContent: 'center',
    padding: theme.spacing.lg,
  },
  title: {
    fontSize: theme.fontSizes.title,
    fontWeight: '700',
    marginBottom: theme.spacing.md,
    textAlign: 'center',
  },
  logo: { alignSelf: 'center', height: 120, width: 120 },
  subtitle: {
    color: theme.colors.grey,
    fontSize: theme.fontSizes.small,
    textAlign: 'center',
  },
  formError: { color: theme.colors.error, textAlign: 'center' },
});
